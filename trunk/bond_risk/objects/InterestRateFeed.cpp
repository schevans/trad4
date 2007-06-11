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

    Notify();
    return true;
}

