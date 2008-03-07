
#include <iostream>
#include <sstream>


#include "trad4.h"
#include "currency_curves.h"
#include "interest_rate_feed.h"

#include "mysql/mysql.h"

extern void* obj_loc[NUM_OBJECTS+1];
extern void* calculate_currency_curves_wrapper( void* id );
extern int create_shmem( void** ret_mem, size_t pub_size );
extern bool currency_curves_need_refresh( int id );

void load_currency_curves( MYSQL* mysql )
{
    std::cout << "load_currency_curvess()" << std::endl;

    MYSQL_RES *result;
    MYSQL_ROW row;

    std::ostringstream dbstream;
    dbstream << "select o.id, o.name , t.interest_rate_feed  from object o , currency_curves t  where  o.id = t.id and  o.type = 2";

    if(mysql_query(mysql, dbstream.str().c_str()) != 0) {
        std::cout << __LINE__ << ": " << mysql_error(mysql) << std::endl;
        exit(0);
    }

    result = mysql_use_result(mysql);

    while (( row = mysql_fetch_row(result) ))
    {
        int id = atoi(row[0]);

        obj_loc[id] = new currency_curves;

        ((currency_curves*)obj_loc[id])->last_published = 0;
        ((currency_curves*)obj_loc[id])->status = STOPPED;
        ((currency_curves*)obj_loc[id])->calculator_fpointer = &calculate_currency_curves_wrapper;
        ((currency_curves*)obj_loc[id])->need_refresh_fpointer = &currency_curves_need_refresh;
        ((currency_curves*)obj_loc[id])->type = 2;
        //((currency_curves*)obj_loc[id])->name = 0;
        
        ((currency_curves*)obj_loc[id])->interest_rate_feed = atoi(row[2]);

        std::cout << "New currency_curves created." << std::endl;
    }

    mysql_free_result(result);
}
