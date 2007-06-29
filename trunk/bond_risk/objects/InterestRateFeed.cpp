#include <sys/ipc.h>
#include <sys/shm.h>
#include <iostream>
#include <fstream>
#include <sstream>

#include "InterestRateFeed.h"

using namespace std;

bool InterestRateFeed::LoadFeedData()
{
    cout << "InterestRateFeed::LoadFeedData()" << endl;

    if ( _feed_file.empty() )
    {

        string feed_data_dir( getenv( "DATA_DIR" ) );

        if ( feed_data_dir.empty() )
        {
            cout << "DATA_DIR not set. Exiting" << endl;
            exit(1);
        }

        ostringstream stream;
        stream << feed_data_dir << _id << "." << Type() << ".t4d";

        _feed_file = stream.str();

    }

    fstream load_file(_feed_file.c_str(), ios::in);

    if ( load_file.is_open() ) 
    {

        char record[MAX_OB_FILE_LEN];

        char* tok;

        int counter(0);

        while ( load_file >> record ) 
        {

            tok = strtok( record, "," );
            ((interest_rate_feed*)_pub)->asof[counter] = atoi(tok);
            tok = strtok( NULL, "," );
            ((interest_rate_feed*)_pub)->rate[counter] = atof(tok);

            counter++;
        }

    }        
    else 
    {
        cout << "Can't open " << _feed_file << ". Exiting." << endl;
        ExitOnError();
    }

    load_file.close();

    int current_period_start;
    int current_period_end;

    double gradient;
    double y_intercept;


    for ( int indx = 0; indx < INTEREST_RATE_LEN - 1 ; indx++)
    {
        current_period_start = ((interest_rate_feed*)_pub)->asof[indx];
        current_period_end = ((interest_rate_feed*)_pub)->asof[indx+1];

        //cout << "Grad calc[" << indx << "]: ( " << local_discount_rate[indx] << " - " << local_discount_rate[indx+1] << ") / (" << _sub_interest_rate_feed->asof[indx] << " - " << _sub_interest_rate_feed->asof[indx+1] << " )" <<  endl;

        gradient = (( ((interest_rate_feed*)_pub)->rate[indx] - ((interest_rate_feed*)_pub)->rate[indx+1] ) / ( ((interest_rate_feed*)_pub)->asof[indx] - ((interest_rate_feed*)_pub)->asof[indx+1] ) );
        y_intercept = ((interest_rate_feed*)_pub)->rate[indx] - gradient * ((interest_rate_feed*)_pub)->asof[indx];

        //cout << current_period_start << " to " << current_period_end << ", start_rate= "<< local_discount_rate[indx] << ", end_rate= << " << local_discount_rate[indx+1] << " gradient: " << gradient << " y-inter:" << y_intercept << endl;

        for ( int i = current_period_start ; i <= current_period_end ; i++ )
        {
            //cout << "\tDate " << i << " index  " << i - DATE_RANGE_START << " rate: " <<(  i*gradient + y_intercept ) << endl;
            ((interest_rate_feed*)_pub)->rate_interpol[i - DATE_RANGE_START] = (  i*gradient + y_intercept );

        }

    }


    Notify();
    return true;
}

