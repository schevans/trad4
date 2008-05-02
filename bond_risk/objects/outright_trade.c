
#include <iostream>

#include "outright_trade_wrapper.c"

using namespace std;

void calculate_outright_trade( obj_loc_t obj_loc, int id )
{
    cout << "calculate_outright_trade()" << endl;

    outright_trade_pv = ( outright_trade_quantity * bond_price / 100 );

    outright_trade_pnl = (( outright_trade_quantity * bond_price / 100 ) - ( outright_trade_quantity * outright_trade_trade_price / 100 ));

    cout << "outright_trade pv=" << outright_trade_pv << ", pnl=" << outright_trade_pnl << endl;
}

