
// Please see the comment at the top of black_scholes/gen/objects/rho_macros.c
//  to see what's in-scope.

#include <iostream>

#include "rho_wrapper.c"

using namespace std;

int calculate_rho( obj_loc_t obj_loc, int id )
{
    if ( option_call_or_put == CALL )
    {
        rho_rho = option_T * rate_trade_KerT * bs_delta_N_pd2;
    }
    else 
    {
        rho_rho = - option_T * rate_trade_KerT * bs_delta_N_md2;
    }

    return 1;
}

