// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

#include <sys/ipc.h>
#include <sys/shm.h>
#include <iostream>

#include "RepoTrade.h"
#include <math.h>

using namespace std;

bool RepoTrade::Calculate()
{
    cout << "RepoTrade::Calculate()" << endl;

//cout << "_cash: " << _cash << ", _notional: " << _notional << ", _sub_bond->price: " <<_sub_bond->price/100.0 << endl;

//cout << "margin: " << _cash - ( _notional * ( _sub_bond->price / 100.0 )) << endl;

    ((repo_trade*)_pub)->margin = GetCash() - ( GetNotional() * ( _sub_bond->price / 100.0 ));

    int duration = GetEndDate() - TODAY;

    double total_end_cash = GetCash() * exp( GetRate()/100.0 * duration / YEAR_BASIS );

    double cash_agg(0);

    for ( int i = 0 ; i < duration ; i++ )
    {
        //cout << "Rate (" << i << "): " << _sub_interest_rate_feed->rate_interpol[i] << endl;
        //cout << "Daily cont (" << i << "): " << ( GetCash() * _sub_interest_rate_feed->rate_interpol[i] / ( 100 * YEAR_BASIS) ) << endl;

        cash_agg = cash_agg + ( GetCash() * _sub_interest_rate_feed->rate_interpol[i] / ( 100 * YEAR_BASIS ));

    }

    SetMtmPnl( cash_agg - total_end_cash );

    return true;
}


