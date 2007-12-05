// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

#include <sys/ipc.h>
#include <sys/shm.h>
#include <iostream>

#include "OutrightTrade.h"

using namespace std;

bool OutrightTrade::Calculate()
{
    cout << "OutrightTrade::Calculate()" << endl;

cout << "quantity=" << GetQuantity() << ", trade_price=" << GetTradePrice() << ", _sub_bond->price=" << _sub_bond->price << endl;

    SetPv( GetQuantity() * _sub_bond->price / 100 );

    SetPnl( ( GetQuantity() * _sub_bond->price / 100 ) - ( GetQuantity() * GetTradePrice() /100 ));

    Notify();
    return true;
}


