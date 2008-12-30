
// Please see the comment at the top of black_scholes/gen/objects/gamma_macros.c
//  to see what's in-scope.

#include <iostream>

#include "gamma_wrapper.c"

using namespace std;

void calculate_gamma( obj_loc_t obj_loc, int id )
{
    gamma_gamma = sbs_delta_N_pd1 / ( sstock_S * sstock_trade_vRtT );
}

