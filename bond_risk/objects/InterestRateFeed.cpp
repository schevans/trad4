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

    fstream load_file(_feed_file.c_str(), ios::in);

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

    load_file.close();
    


    Notify();
    return true;
}

InterestRateFeed::InterestRateFeed( int id )
{
    cout << "InterestRateFeed::InterestRateFeed: "<< id << endl;

//    _pub = (interest_rate_feed*)CreateShmem(sizeof(interest_rate_feed));

    Init( id );

    string data_dir( getenv( "DATA_DIR" ) );

    if ( data_dir.empty() )
    {
        cout << "DATA_DIR not set. Exiting" << endl;
        exit(1);
    }

    ostringstream stream;
    stream << data_dir << _id << "." << Type() << ".t4d";

    _feed_file = stream.str();


cout << "data_file_name: " << _feed_file << endl;



}

