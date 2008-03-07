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

extern void load_bonds( MYSQL* mysql );
extern void load_interest_rate_feeds( MYSQL* mysql );
extern void load_currency_curves( MYSQL* mysql );
extern void load_outright_trades( MYSQL* mysql );
extern void load_repo_trades( MYSQL* mysql );

/*
void load_bonds()
{
    ostringstream dbstream;
    dbstream << "select o.id, type, name, b.coupon, b.start_date, b.maturity_date, b.coupons_per_year, b.currency_curves from object o, bond b where b.id = o.id and type=3";

    if(mysql_query(&mysql, dbstream.str().c_str()) != 0) {
        cout << __LINE__ << ": " << mysql_error(&mysql) << endl;
    }

    result = mysql_use_result(&mysql);

    while (( row = mysql_fetch_row(result) )) {

        int id = atoi(row[0]);

        obj_loc[id] = new bond;

        ((bond*)obj_loc[id])->last_published = 0;
        ((bond*)obj_loc[id])->status = STOPPED;
        ((bond*)obj_loc[id])->calculator_fpointer = &calculate_bond_wrapper;
        ((bond*)obj_loc[id])->need_refresh_fpointer = &bond_need_refresh;
        ((bond*)obj_loc[id])->type = 0;
    //    ((bond*)obj_loc[id])->name = 0;

        ((bond*)obj_loc[id])->currency_curves = atoi(row[7]);
        ((bond*)obj_loc[id])->coupon = atof(row[3]);
        ((bond*)obj_loc[id])->start_date = atoi(row[4]);
        ((bond*)obj_loc[id])->maturity_date = atoi(row[5]);
        ((bond*)obj_loc[id])->coupons_per_year = atoi(row[6]);
        ((bond*)obj_loc[id])->price = 0.0;
        ((bond*)obj_loc[id])->dv01 = 0.0;

        cout << "New bond created" << endl;
    }

    mysql_free_result(result);
}

void load_outright_trades()
{
    ostringstream dbstream;
    dbstream << "select ou.id, ou.quantity, ou.trade_date, ou.trade_price, ou.bond from outright_trade ou, object o where ou.id=o.id and type=4";

    if(mysql_query(&mysql, dbstream.str().c_str()) != 0) {
        cout << __LINE__ << ": " << mysql_error(&mysql) << endl;
    }

    result = mysql_use_result(&mysql);

    while (( row = mysql_fetch_row(result) )) {

        int id = atoi(row[0]);

        obj_loc[id] = new outright_trade;

        ((outright_trade*)obj_loc[id])->last_published = 0;
        ((outright_trade*)obj_loc[id])->status = STOPPED;
        ((outright_trade*)obj_loc[id])->calculator_fpointer = &calculate_outright_trade_wrapper;
        ((outright_trade*)obj_loc[id])->need_refresh_fpointer = &outright_trade_need_refresh;
        ((outright_trade*)obj_loc[id])->type = 0;
    //    ((outright_trade*)obj_loc[id])->name = 0;

        ((outright_trade*)obj_loc[id])->bond = atoi(row[4]);
        ((outright_trade*)obj_loc[id])->quantity = atoi(row[1]);
        ((outright_trade*)obj_loc[id])->trade_date = atoi(row[2]);
        ((outright_trade*)obj_loc[id])->trade_price = atof(row[3]);

        cout << "New outright_trade created" << endl;

    }

    mysql_free_result(result);
}



void load_currency_curves()
{
    ostringstream dbstream;
    dbstream << "select c.id, c.interest_rate_feed from currency_curves c, object o where o.id=c.id and type=2";

    if(mysql_query(&mysql, dbstream.str().c_str()) != 0) {
        cout << __LINE__ << ": " << mysql_error(&mysql) << endl;
    }

    result = mysql_use_result(&mysql);

    while (( row = mysql_fetch_row(result) )) {

        int id = atoi(row[0]);

        obj_loc[id] = new currency_curves;

        ((currency_curves*)obj_loc[id])->last_published = 0;
        ((currency_curves*)obj_loc[id])->status = STOPPED;
        ((currency_curves*)obj_loc[id])->calculator_fpointer = &calculate_currency_curves_wrapper;
        ((currency_curves*)obj_loc[id])->need_refresh_fpointer = &currency_curves_need_refresh;
        ((currency_curves*)obj_loc[id])->type = 0;
    //    ((currency_curves*)obj_loc[id])->name = 0;

        ((currency_curves*)obj_loc[id])->interest_rate_feed = atoi(row[1]);

        cout << "New currency_curves created" << endl;

    }

    mysql_free_result(result);
}
*/
void load_all()
{
    mysql_init(&mysql);

    if (!mysql_real_connect(&mysql,"localhost", "root", NULL,"trad4",0,NULL,0)) {
        cout << __LINE__ << " "  << mysql_error(&mysql) << endl;
    }

    load_interest_rate_feeds( &mysql );
    load_currency_curves( &mysql);
    load_bonds( &mysql);
    load_outright_trades( &mysql);
    load_repo_trades( &mysql );
    
}





