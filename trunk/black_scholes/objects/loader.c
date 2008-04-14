
#include <iostream>
#include <sstream>
#include <vector>

#include "trad4.h"
#include "common.h"
#include "option_feed.h"
#include "risk_free_rate_feed.h"
#include "stock_feed.h"
#include "stock_trade.h"
#include "rate_trade.h"
#include "bs_delta.h"
#include "kertn_d2.h"
#include "vega.h"
#include "theta.h"
#include "price.h"
#include "rho.h"

#include "mysql/mysql.h"

MYSQL mysql;
MYSQL_RES *result;
MYSQL_ROW row;

extern void* obj_loc[NUM_OBJECTS+1];

extern void load_option_feed( MYSQL* mysql, int id );
extern void load_all_option_feed( MYSQL* mysql );
extern void load_risk_free_rate_feed( MYSQL* mysql, int id );
extern void load_all_risk_free_rate_feed( MYSQL* mysql );
extern void load_stock_feed( MYSQL* mysql, int id );
extern void load_all_stock_feed( MYSQL* mysql );
extern void load_stock_trade( MYSQL* mysql, int id );
extern void load_all_stock_trade( MYSQL* mysql );
extern void load_rate_trade( MYSQL* mysql, int id );
extern void load_all_rate_trade( MYSQL* mysql );
extern void load_bs_delta( MYSQL* mysql, int id );
extern void load_all_bs_delta( MYSQL* mysql );
extern void load_kertn_d2( MYSQL* mysql, int id );
extern void load_all_kertn_d2( MYSQL* mysql );
extern void load_vega( MYSQL* mysql, int id );
extern void load_all_vega( MYSQL* mysql );
extern void load_theta( MYSQL* mysql, int id );
extern void load_all_theta( MYSQL* mysql );
extern void load_price( MYSQL* mysql, int id );
extern void load_all_price( MYSQL* mysql );
extern void load_rho( MYSQL* mysql, int id );
extern void load_all_rho( MYSQL* mysql );

extern int tier_manager[NUM_TIERS+1][NUM_OBJECTS+1];

using namespace std;

void load_all()
{
    mysql_init(&mysql);

    if (!mysql_real_connect(&mysql,"localhost", "root", NULL,"black_scholes",0,NULL,0))
    {
        std::cout << __LINE__ << " "  << mysql_error(&mysql) << std::endl;
    }

    tier_manager[1][0]=1;
    tier_manager[2][0]=1;
    tier_manager[3][0]=1;
    tier_manager[4][0]=1;
    tier_manager[5][0]=1;

    load_all_option_feed( &mysql );
    load_all_risk_free_rate_feed( &mysql );
    load_all_stock_feed( &mysql );
    load_all_stock_trade( &mysql );
    load_all_rate_trade( &mysql );
    load_all_bs_delta( &mysql );
    load_all_kertn_d2( &mysql );
    load_all_vega( &mysql );
    load_all_theta( &mysql );
    load_all_price( &mysql );
    load_all_rho( &mysql );

}
void reload_objects()
{
    MYSQL_RES *result;
    MYSQL_ROW row;

    std::ostringstream dbstream;
    dbstream << "select id, type from object where need_reload=1";

    if(mysql_query(&mysql, dbstream.str().c_str()) != 0) {
        std::cout << __LINE__ << ": " << mysql_error(&mysql) << std::endl;
        exit(0);
    }

    result = mysql_use_result(&mysql);

    std::vector<int> id_vec;
    std::vector<int> type_vec;

    while (( row = mysql_fetch_row(result) ))
    {
        id_vec.push_back(atoi(row[0]));
        type_vec.push_back(atoi(row[1]));
    }

    mysql_free_result(result);

    for( int i = 0 ; i < id_vec.size() ; i++ )
    {
        int id = id_vec[i];
        int type = type_vec[i];

        switch( type )
        {

            case 1:
                load_option_feed( &mysql, id );
                break;
            case 2:
                load_risk_free_rate_feed( &mysql, id );
                break;
            case 3:
                load_stock_feed( &mysql, id );
                break;
            case 4:
                load_stock_trade( &mysql, id );
                break;
            case 5:
                load_rate_trade( &mysql, id );
                break;
            case 6:
                load_bs_delta( &mysql, id );
                break;
            case 7:
                load_kertn_d2( &mysql, id );
                break;
            case 8:
                load_vega( &mysql, id );
                break;
            case 9:
                load_theta( &mysql, id );
                break;
            case 10:
                load_price( &mysql, id );
                break;
            case 11:
                load_rho( &mysql, id );
                break;
            default:
                std::cout << "Unknown type " << type << std::endl;
                exit(0);

        }
    }
}
