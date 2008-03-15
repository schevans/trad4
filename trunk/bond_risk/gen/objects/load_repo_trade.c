
#include <iostream>
#include <sstream>


#include "trad4.h"
#include "repo_trade.h"
#include "bond.h"
#include "currency_curves.h"

#include "mysql/mysql.h"

extern void* obj_loc[NUM_OBJECTS+1];
extern void* calculate_repo_trade_wrapper( void* id );
extern int create_shmem( void** ret_mem, size_t pub_size );
extern bool repo_trade_need_refresh( int id );
extern int tier_manager[NUM_TIERS+1][NUM_OBJECTS+1];

void load_repo_trade( MYSQL* mysql )
{
    // std::cout << "load_repo_trades()" << std::endl;

    MYSQL_RES *result;
    MYSQL_ROW row;

    std::ostringstream dbstream;
    dbstream << "select o.id, o.name , t.start_date , t.end_date , t.notional , t.cash_ccy , t.rate , t.cash , t.book , t.bond , t.currency_curves  from object o , repo_trade t  where  o.id = t.id and  o.type = 5";

    if(mysql_query(mysql, dbstream.str().c_str()) != 0) {
        std::cout << __LINE__ << ": " << mysql_error(mysql) << std::endl;
        exit(0);
    }

    result = mysql_use_result(mysql);

    while (( row = mysql_fetch_row(result) ))
    {
        int id = atoi(row[0]);

        obj_loc[id] = new repo_trade;

        ((repo_trade*)obj_loc[id])->last_published = 0;
        ((repo_trade*)obj_loc[id])->status = STOPPED;
        ((repo_trade*)obj_loc[id])->calculator_fpointer = &calculate_repo_trade_wrapper;
        ((repo_trade*)obj_loc[id])->need_refresh_fpointer = &repo_trade_need_refresh;
        ((repo_trade*)obj_loc[id])->type = 5;
        //((repo_trade*)obj_loc[id])->name = 0;
        
        ((repo_trade*)obj_loc[id])->start_date = atoi(row[2]);
        ((repo_trade*)obj_loc[id])->end_date = atoi(row[3]);
        ((repo_trade*)obj_loc[id])->notional = atoi(row[4]);
        ((repo_trade*)obj_loc[id])->cash_ccy = atoi(row[5]);
        ((repo_trade*)obj_loc[id])->rate = atof(row[6]);
        ((repo_trade*)obj_loc[id])->cash = atof(row[7]);
        ((repo_trade*)obj_loc[id])->book = atoi(row[8]);
        ((repo_trade*)obj_loc[id])->bond = atoi(row[9]);
        ((repo_trade*)obj_loc[id])->currency_curves = atoi(row[10]);

        tier_manager[4][tier_manager[4][0]] = id;
        tier_manager[4][0]++;

    }

    std::cout << "Repo_trades loaded." << std::endl;

    mysql_free_result(result);
}
