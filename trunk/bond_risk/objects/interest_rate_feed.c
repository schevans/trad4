// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk
//

#include <iostream>
#include <sstream>
#include <fstream>
#include <vector>
#include "mysql/mysql.h"

#include "interest_rate_feed_wrapper.c"

extern void* obj_loc[NUM_OBJECTS+1];
extern void set_timestamp( int id );

extern void* calculate_interest_rate_feed( void* id );
extern int create_shmem( void** ret_mem, size_t pub_size );

using namespace std;

void* calculate_interest_rate_feed( interest_rate_feed* pub_interest_rate_feed )
{
    //cout << "calculate_interest_rate_feed()" << endl;

    for ( int i=0 ; i < INTEREST_RATE_LEN - 1 ; i++ )
    {
        pub_interest_rate_feed->asof[i] = (pub_interest_rate_feed->sub)->asof[i];
        pub_interest_rate_feed->rate[i] = (pub_interest_rate_feed->sub)->rate[i];

    }

}
/*
void load_interest_rate_feeds( MYSQL* mysql )
{
    //cout << "load_interest_rate_feeds()" << endl;

    MYSQL_RES *result;
    MYSQL_ROW row;

    ostringstream dbstream;
    dbstream << "select id, name from object where type=1";

DBG
    if(mysql_query(mysql, dbstream.str().c_str()) != 0) {
        cout << __LINE__ << ": " << mysql_error(mysql) << endl;
    }

DBG
    result = mysql_use_result(mysql);

DBG
    int id;
    std::string name;
    void* tmp;
DBG
   std::vector<int> interest_rates;

    while (( row = mysql_fetch_row(result) )) {

DBG
       id = atoi(row[0]);
       name = row[2];

        obj_loc[id] = new interest_rate_feed;
        ((interest_rate_feed*)obj_loc[id])->last_published = 0;
DBG
        ((interest_rate_feed*)obj_loc[id])->status = STOPPED;
        ((interest_rate_feed*)obj_loc[id])->calculator_fpointer = &calculate_interest_rate_feed_wrapper;
        ((interest_rate_feed*)obj_loc[id])->need_refresh_fpointer = &interest_rate_feed_need_refresh;
        ((interest_rate_feed*)obj_loc[id])->type = 1;
DBG
    //    ((interest_rate_feed*)obj_loc[id])->name = 0;


        ((interest_rate_feed*)obj_loc[id])->shmid = create_shmem( &tmp, sizeof( interest_rate_feed_sub ) );
DBG
        ((interest_rate_feed*)obj_loc[id])->sub = (interest_rate_feed_sub*)tmp;
//        (((interest_rate_feed*)obj_loc[id])->sub)->sub = 0;
DBG

        (((interest_rate_feed*)obj_loc[id])->sub)->last_published = 0;
DBG

        interest_rates.push_back( id );

    }

    mysql_free_result(result);

    fstream save_file("/tmp/interest_rate_feed.txt", ios::out);

    vector<int>::iterator iter;

    for( iter = interest_rates.begin() ; iter < interest_rates.end() ; iter++ )
    {
        save_file << *iter << "," << ((interest_rate_feed*)obj_loc[*iter])->shmid << endl;

        for ( int i=0 ; i < INTEREST_RATE_LEN - 1 ; i++ )
        {    
            ((interest_rate_feed*)obj_loc[(int)id])->asof[i] = 0;
            ((interest_rate_feed*)obj_loc[(int)id])->rate[i] = 0;
        }
    }
    
    save_file.close();
}
*/
