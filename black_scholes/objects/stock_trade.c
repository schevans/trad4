
// Please see the comment at the top of black_scholes/gen/objects/stock_trade_macros.c
//  to see what's in-scope.

#include <iostream>
#include <math.h>

#include "stock_trade_wrapper.c"

using namespace std;

int calculate_stock_trade( obj_loc_t obj_loc, int id )
{
    stock_trade_ln_SK = log( sstock_S / soption_K );

    stock_trade_vvT_2 = ( sstock_vv * soption_T ) / 2.0;

    stock_trade_vRtT = sstock_v * soption_RtT;

    return 1;
}

