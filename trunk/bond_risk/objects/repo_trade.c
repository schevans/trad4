// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk
//

#include <iostream>
#include <math.h>

#include "repo_trade_wrapper.c"

using namespace std;

int calculate_repo_trade( obj_loc_t obj_loc, int id )
{
    // First calculate the margin - the difference between the cash we borrowed and the value
    // of the bond collateral.
    repo_trade_margin = repo_trade_start_cash - ( repo_trade_notional * bond_price );

    // Next, calculate the cost it would cost us to borrow this money today, given the
    // currenct interest rates.

    // First calculate the durateion - the number of days left in the trade.
    int duration = repo_trade_end_date - calendar_today;

    // Next, calculate the end cash amount. This is a given at the start of the trade, so calculated
    // from it's static.
    repo_trade_end_cash = repo_trade_start_cash * exp( repo_trade_rate * ( duration / YEAR_BASIS ));

    // Next calculate the sum of the daily interest given our ir_curve.
    double cash_agg(0);

    for ( int i = 0 ; i < duration ; i++ )
    {
        cash_agg = cash_agg + ( repo_trade_start_cash * ( ir_curve_discount_rate[i] * ( 1 / YEAR_BASIS )));
    }

    // The mtm_pnl is the differnce between what the trade cost us to borrow the cash and what it would
    // cost on the open market now.
    repo_trade_mtm_pnl = repo_trade_end_cash - cash_agg;

    return 1;
}

