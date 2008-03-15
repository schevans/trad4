// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk
//

#include <iostream>
#include <sstream>
#include <vector>

#include "trad4.h"
#include "common.h"
#include "bond.h"
#include "currency_curves.h"
#include "interest_rate_feed.h"
#include "outright_trade.h"

#include "mysql/mysql.h"

MYSQL mysql;
MYSQL_RES *result;
MYSQL_ROW row;


extern void* obj_loc[NUM_OBJECTS+1];

extern bool bond_need_refresh( int );
extern bool currency_curves_need_refresh( int id );
extern bool outright_trade_need_refresh( int id );

// Provided by the user.
extern void* calculate_bond_wrapper( void* id );
extern void* calculate_currency_curves_wrapper( void* id );
extern void* calculate_outright_trade_wrapper( void* id );

using namespace std;

extern void load_bond( MYSQL* mysql );
extern void load_interest_rate_feed( MYSQL* mysql );
extern void load_currency_curves( MYSQL* mysql );
extern void load_outright_trade( MYSQL* mysql );
extern void load_repo_trade( MYSQL* mysql );

extern int tier_manager[NUM_TIERS+1][NUM_OBJECTS+1];

void load_all()
{
    mysql_init(&mysql);

    if (!mysql_real_connect(&mysql,"localhost", "root", NULL,"trad4",0,NULL,0)) {
        cout << __LINE__ << " "  << mysql_error(&mysql) << endl;
    }

    tier_manager[1][0]=1;
    tier_manager[2][0]=1;
    tier_manager[3][0]=1;
    tier_manager[4][0]=1;

    load_interest_rate_feed( &mysql );
    load_currency_curves( &mysql);
    load_bond( &mysql);
    load_outright_trade( &mysql);
    load_repo_trade( &mysql );
    
}





