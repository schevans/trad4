
#include <iostream>
#include <math.h>

#include "repo_trade_wrapper.c"

using namespace std;

void* calculate_repo_trade( repo_trade* pub_repo_trade , bond* sub_bond , currency_curves* sub_currency_curves )
{
    //cout << "calculate_repo_trade()" << endl;

//cout << "_cash: " << _cash << ", _notional: " << _notional << ", sub_bond->price: " <<sub_bond->price/100.0 << endl;

//cout << "margin: " << _cash - ( _notional * ( sub_bond->price / 100.0 )) << endl;

    pub_repo_trade->margin = pub_repo_trade->cash - ( pub_repo_trade->notional * ( sub_bond->price / 100.0 ));

    int duration = pub_repo_trade->end_date - TODAY;

    double total_end_cash = pub_repo_trade->cash * exp( ( pub_repo_trade->rate / 100.0 ) * duration / YEAR_BASIS );

    double cash_agg(0);

    for ( int i = 0 ; i < duration ; i++ )
    {
        //cout << "Rate (" << i << "): " << sub_currency_curves->interest_rate_interpol[i] << endl;
        //cout << "Daily cont (" << i << "): " << ( pub_repo_trade->cash * sub_currency_curves->interest_rate_interpol[i] / ( 100 * YEAR_BASIS) ) << endl;

        cash_agg = cash_agg + ( pub_repo_trade->cash * sub_currency_curves->interest_rate_interpol[i] / ( 100 * YEAR_BASIS ));

    }

    pub_repo_trade->mtm_pnl = ( cash_agg - total_end_cash );

    //cout << "repo_trade margin=" << pub_repo_trade->margin << ", mtm_pnl=" << pub_repo_trade->mtm_pnl << endl;
}

