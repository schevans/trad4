// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk
//

#include <iostream>

#include "outright_trade_wrapper.c"

using namespace std;

int calculate_outright_trade( obj_loc_t obj_loc, int id )
{
    // Calculate the pv - the present value of the trade.
    outright_trade_pv = ( outright_trade_quantity * bond_price );

    // Calculate the pv01 - the pv's exposure to interest rate movements.
    outright_trade_pv_01 = ( outright_trade_quantity * bond_pv01 );

    // Calculate the pnl - the profit or loss we would make on the trade if we re-sold these bonds today.
    outright_trade_pnl = outright_trade_pv - ( outright_trade_quantity * outright_trade_trade_price );

    return 1;
}

