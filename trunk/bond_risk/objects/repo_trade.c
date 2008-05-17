
#include <iostream>
#include <math.h>

#include "repo_trade_wrapper.c"

using namespace std;

void calculate_repo_trade( obj_loc_t obj_loc, int id )
{
    //cout << "calculate_repo_trade()" << endl;

//cout << "_cash: " << _cash << ", _notional: " << _notional << ", sub_bond->price: " <<sub_bond->price/100.0 << endl;

//cout << "margin: " << _cash - ( _notional * ( sub_bond->price / 100.0 )) << endl;

    repo_trade_margin = repo_trade_cash - ( repo_trade_notional * ( bond_price / 100.0 ));

    int duration = repo_trade_end_date - TODAY;

    double total_end_cash = repo_trade_cash * exp( ( repo_trade_rate / 100.0 ) * duration / YEAR_BASIS );

    double cash_agg(0);

    for ( int i = 0 ; i < duration ; i++ )
    {
        //cout << "Rate (" << i << "): " << sub_currency_curves->interest_rate_interpol[i] << endl;
        //cout << "Daily cont (" << i << "): " << ( pub_repo_trade->cash * sub_currency_curves->interest_rate_interpol[i] / ( 100 * YEAR_BASIS) ) << endl;

        cash_agg = cash_agg + ( repo_trade_cash * currency_curves_interest_rate_interpol[i] / ( 100 * YEAR_BASIS ));

    }

    repo_trade_mtm_pnl = ( cash_agg - total_end_cash );

    cout << "repo_trade margin=" << repo_trade_margin << ", mtm_pnl=" << repo_trade_mtm_pnl << endl;
}

