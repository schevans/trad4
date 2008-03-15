
#include <iostream>
#include <sstream>
#include <vector>
#include <fstream>



#include "trad4.h"
#include "interest_rate_feed.h"

#include "mysql/mysql.h"

extern void* obj_loc[NUM_OBJECTS+1];
extern void* calculate_interest_rate_feed_wrapper( void* id );
extern int create_shmem( void** ret_mem, size_t pub_size );
extern bool interest_rate_feed_need_refresh( int id );
extern int tier_manager[NUM_TIERS+1][NUM_OBJECTS+1];

using namespace std;

void load_interest_rate_feed( MYSQL* mysql )
{
    // cout << "load_interest_rate_feeds()" << endl;

    MYSQL_RES *result;
    MYSQL_ROW row;

    ostringstream dbstream;
    dbstream << "select id, name from object where type=1";

    if(mysql_query(mysql, dbstream.str().c_str()) != 0) {
        cout << __LINE__ << ": " << mysql_error(mysql) << endl;
    }

    result = mysql_use_result(mysql);

    int id;
    std::string name;
    void* tmp;
   std::vector<int> interest_rates;

    while (( row = mysql_fetch_row(result) )) {

       id = atoi(row[0]);
       name = row[2];

        obj_loc[id] = new interest_rate_feed;
        ((interest_rate_feed*)obj_loc[id])->last_published = 0;
        ((interest_rate_feed*)obj_loc[id])->status = STOPPED;
        ((interest_rate_feed*)obj_loc[id])->calculator_fpointer = &calculate_interest_rate_feed_wrapper;
        ((interest_rate_feed*)obj_loc[id])->need_refresh_fpointer = &interest_rate_feed_need_refresh;
        ((interest_rate_feed*)obj_loc[id])->type = 1;
    //    ((interest_rate_feed*)obj_loc[id])->name = 0;


        ((interest_rate_feed*)obj_loc[id])->shmid = create_shmem( &tmp, sizeof( interest_rate_feed_sub ) );
        ((interest_rate_feed*)obj_loc[id])->sub = (interest_rate_feed_sub*)tmp;
//        (((interest_rate_feed*)obj_loc[id])->sub)->sub = 0;

        (((interest_rate_feed*)obj_loc[id])->sub)->last_published = 0;

        interest_rates.push_back( id );

        tier_manager[1][tier_manager[1][0]] = id;
        tier_manager[1][0]++;

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

    cout << "Interest_rate_feeds loaded." << endl;

    save_file.close();

}
