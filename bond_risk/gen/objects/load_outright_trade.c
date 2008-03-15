
#include <iostream>
#include <sstream>


#include "trad4.h"
#include "outright_trade.h"
#include "bond.h"

#include "mysql/mysql.h"

extern void* obj_loc[NUM_OBJECTS+1];
extern void* calculate_outright_trade_wrapper( void* id );
extern int create_shmem( void** ret_mem, size_t pub_size );
extern bool outright_trade_need_refresh( int id );
extern int tier_manager[NUM_TIERS+1][NUM_OBJECTS+1];

void load_outright_trade( MYSQL* mysql )
{
    // std::cout << "load_outright_trades()" << std::endl;

    MYSQL_RES *result;
    MYSQL_ROW row;

    std::ostringstream dbstream;
    dbstream << "select o.id, o.name , t.quantity , t.trade_date , t.trade_price , t.book , t.bond  from object o , outright_trade t  where  o.id = t.id and  o.type = 4";

    if(mysql_query(mysql, dbstream.str().c_str()) != 0) {
        std::cout << __LINE__ << ": " << mysql_error(mysql) << std::endl;
        exit(0);
    }

    result = mysql_use_result(mysql);

    while (( row = mysql_fetch_row(result) ))
    {
        int id = atoi(row[0]);

        obj_loc[id] = new outright_trade;

        ((outright_trade*)obj_loc[id])->last_published = 0;
        ((outright_trade*)obj_loc[id])->status = STOPPED;
        ((outright_trade*)obj_loc[id])->calculator_fpointer = &calculate_outright_trade_wrapper;
        ((outright_trade*)obj_loc[id])->need_refresh_fpointer = &outright_trade_need_refresh;
        ((outright_trade*)obj_loc[id])->type = 4;
        //((outright_trade*)obj_loc[id])->name = 0;
        
        ((outright_trade*)obj_loc[id])->quantity = atoi(row[2]);
        ((outright_trade*)obj_loc[id])->trade_date = atoi(row[3]);
        ((outright_trade*)obj_loc[id])->trade_price = atof(row[4]);
        ((outright_trade*)obj_loc[id])->book = atoi(row[5]);
        ((outright_trade*)obj_loc[id])->bond = atoi(row[6]);

        tier_manager[4][tier_manager[4][0]] = id;
        tier_manager[4][0]++;

    }

    std::cout << "Outright_trades loaded." << std::endl;

    mysql_free_result(result);
}
