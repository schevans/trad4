
// Please see the comment at the top of black_scholes/gen/objects/theta_macros.c
//  to see what's in-scope.

#include <iostream>

#include "theta_wrapper.c"

using namespace std;

int calculate_theta( obj_loc_t obj_loc, int id )
{
    if ( soption_call_or_put == CALL )
    {
        theta_theta = (( - sstock_S * sbs_delta_N_pd1 * sstock_v ) / ( 2.0 * soption_RtT )) - ( srate_trade_rKerT * sbs_delta_N_pd2 );
    }
    else
    {
        theta_theta = (( - sstock_S * sbs_delta_N_pd1 * sstock_v ) / ( 2.0 * soption_RtT )) + ( srate_trade_rKerT * sbs_delta_N_md2 );
    }

    return 1;
}

