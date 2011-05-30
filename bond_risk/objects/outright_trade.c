// Copyright (c) Steve Evans 2010
// schevans@users.sourceforge.net
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE


#include <iostream>

#include "outright_trade_wrapper.c"

using namespace std;

int calculate_outright_trade( obj_loc_t obj_loc, long id )
{
    double direction = ( outright_trade_buy_sell == BUY ? 1.0 : -1.0 );

    // Calculate the pv - the present value of the trade.
    outright_trade_pv = ( outright_trade_quantity * bond_price ) * direction;

    // Calculate the pv01 - the pv's exposure to interest rate movements.
    outright_trade_pv_01 = ( outright_trade_quantity * bond_pv01 ) * direction;

    // Calculate the pnl - the profit or loss we would make on the trade if we re-sold these bonds today.
    outright_trade_pnl = outright_trade_pv - ( outright_trade_quantity * outright_trade_trade_price ) * direction;

    return 1;
}

