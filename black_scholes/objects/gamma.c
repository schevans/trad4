
// Please see the comment at the top of black_scholes/gen/objects/gamma_macros.c
//  to see what's in-scope.

#include <iostream>

#include "gamma_wrapper.c"

using namespace std;

void calculate_gamma( obj_loc_t obj_loc, int id )
{
    DEBUG( "calculate_gamma( " << id << " )" )

    gamma_gamma = bs_delta_N_pd1 / ( stock_S * stock_trade_vRtT );
}

