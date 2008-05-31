// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk
//

#include <iostream>
#include <vector>

#include "interest_rate_feed_wrapper.c"

using namespace std;

static int counter(1);

void calculate_interest_rate_feed( obj_loc_t obj_loc, int id )
{
    cout << "calculate_interest_rate_feed()" << endl;

}

static int extra_loader_callback( void *obj_loc_v, int argc, char **row, char **azColName )
{
    // Have to cast to unsigned char** here as C++ doesn't like
    //  void* arithmetic for some reason...
    unsigned char** obj_loc = (unsigned char**)obj_loc_v;

DBG
    int id = atoi(row[0]);
DBG

cout << "id: " << id << ", ct: " << counter << ", d: " << atoi(row[1]) << ", r: " << atof(row[2]) << endl;

    interest_rate_feed_asof[counter]  = atoi(row[1]);
DBG
    interest_rate_feed_rate[counter]  = atof(row[2]);
DBG
   
    counter++;
 
    return 0;
}

void extra_loader( obj_loc_t obj_loc, int id, sqlite3* db )
{
    cout << "extra_loader()" << endl;

    counter = 0;
    char *zErrMsg = 0;

    ostringstream dbstream;
    dbstream << "select id, asof, rate from interest_rate_feed_data where id=" << id;

    if( sqlite3_exec(db, dbstream.str().c_str(), extra_loader_callback, obj_loc, &zErrMsg) != SQLITE_OK ){
        fprintf(stderr, "SQL error: %s\n", zErrMsg);
        sqlite3_free(zErrMsg);
    }

}
