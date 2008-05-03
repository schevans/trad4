// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk
//

#include <iostream>
#include <vector>

#include "interest_rate_feed_wrapper.c"

using namespace std;

void calculate_interest_rate_feed( obj_loc_t obj_loc, int id )
{
    cout << "calculate_interest_rate_feed()" << endl;

}

void extra_loader( obj_loc_t obj_loc, int id, MYSQL& mysql )
{
    cout << "extra_loader()" << endl;

    MYSQL_RES *result;
    MYSQL_ROW row;

    ostringstream dbstream;
    dbstream << "select asof, rate from interest_rate_feed_data where id=" << id;

    if(mysql_query(&mysql, dbstream.str().c_str()) != 0) {
        cout << __LINE__ << ": " << mysql_error(&mysql) << endl;
    }

    result = mysql_use_result(&mysql);

    int counter(0);

    while (( row = mysql_fetch_row(result) )) {

        interest_rate_feed_asof[counter]  = atoi(row[0]);
        interest_rate_feed_rate[counter]  = atof(row[1]);

        counter++;
    }

    mysql_free_result(result);

}
