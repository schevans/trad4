
// Please see the comment at the top of black_scholes/gen/objects/rate_trade_macros.c
//  to see what's in-scope.

#include <iostream>
#include <math.h>

#include "rate_trade_wrapper.c"

using namespace std;

void calculate_rate_trade( obj_loc_t obj_loc, int id )
{
    rate_trade_rT = srisk_free_rate_r * soption_T;

    rate_trade_KerT = soption_K * exp( - rate_trade_rT );

    rate_trade_rKerT = srisk_free_rate_r * rate_trade_KerT;
}

