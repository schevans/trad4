// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

#include <sys/ipc.h>
#include <sys/shm.h>
#include <iostream>

#include "OutrightTradeAgg.h"
#include "outright_trade.h"

using namespace std;

bool OutrightTradeAgg::Calculate()
{
    cout << "OutrightTradeAgg::Calculate()" << endl;

    vector<int>::iterator iter;
    for( iter = _element_ids.begin() ; iter < _element_ids.end() ; iter++ )
    {
        _pvs[*iter] = ((outright_trade*)(_elements_map[*iter]))->pv;
        _acc_pv = _acc_pv + ((outright_trade*)(_elements_map[*iter]))->pv;

        _pnls[*iter] = ((outright_trade*)(_elements_map[*iter]))->pnl;
        _acc_pnl = _acc_pnl + ((outright_trade*)(_elements_map[*iter]))->pnl;

        _dv01s[*iter] = ((outright_trade*)(_elements_map[*iter]))->dv01;
        _acc_dv01 = _acc_dv01 + ((outright_trade*)(_elements_map[*iter]))->dv01;

    }

    SetPv( _acc_pv );
    SetPnl( _acc_pnl );
    SetDv01( _acc_dv01 );
    

    Notify();
    return true;
}

