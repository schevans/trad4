
#include <iostream>
#include <sstream>

#include "trad4.h"
#include "common.h"
#include "option_feed.h"
#include "risk_free_rate_feed.h"
#include "stock_feed.h"
#include "rate_trade.h"
#include "stock_trade.h"
#include "bs_delta.h"
#include "theta.h"
#include "kertn_pd2.h"
#include "vega.h"
#include "gamma.h"
#include "sn_pd1.h"
#include "rho.h"
#include "price.h"
#include "listener.h"

#include "mysql/mysql.h"

MYSQL mysql;
MYSQL_RES *result;
MYSQL_ROW row;

extern void* obj_loc[NUM_OBJECTS+1];

extern void load_option_feed( MYSQL* mysql );
extern void load_risk_free_rate_feed( MYSQL* mysql );
extern void load_stock_feed( MYSQL* mysql );
extern void load_rate_trade( MYSQL* mysql );
extern void load_stock_trade( MYSQL* mysql );
extern void load_bs_delta( MYSQL* mysql );
extern void load_theta( MYSQL* mysql );
extern void load_kertn_pd2( MYSQL* mysql );
extern void load_vega( MYSQL* mysql );
extern void load_gamma( MYSQL* mysql );
extern void load_sn_pd1( MYSQL* mysql );
extern void load_rho( MYSQL* mysql );
extern void load_price( MYSQL* mysql );
extern void load_listener( MYSQL* mysql );

extern int tier_manager[NUM_TIERS+1][NUM_OBJECTS+1];

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

    load_option_feed( &mysql );
    load_risk_free_rate_feed( &mysql );
    load_stock_feed( &mysql );
    load_rate_trade( &mysql );
    load_stock_trade( &mysql );
    load_bs_delta( &mysql );
    load_theta( &mysql );
    load_kertn_pd2( &mysql );
    load_vega( &mysql );
    load_gamma( &mysql );
    load_sn_pd1( &mysql );
    load_rho( &mysql );
    load_price( &mysql );
    load_listener( &mysql );

}
