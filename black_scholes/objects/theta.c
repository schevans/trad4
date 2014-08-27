
// Please see the comment at the top of black_scholes/gen/objects/theta_macros.c
//  to see what's in-scope.

#include <iostream>

#include "theta_wrapper.c"

using namespace std;

int calculate_theta( obj_loc_t obj_loc, long id )
{
    if ( option_call_or_put == CALL )
    {
        theta_theta = (( - stock_S * bs_delta_N_pd1 * stock_v ) / ( 2.0 * option_RtT )) - ( rate_trade_rKerT * bs_delta_N_pd2 );
    }
    else
    {
        theta_theta = (( - stock_S * bs_delta_N_pd1 * stock_v ) / ( 2.0 * option_RtT )) + ( rate_trade_rKerT * bs_delta_N_md2 );
    }

    return 1;
}

