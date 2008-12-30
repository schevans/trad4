
// Please see the comment at the top of black_scholes/gen/objects/rho_macros.c
//  to see what's in-scope.

#include <iostream>

#include "rho_wrapper.c"

using namespace std;

void calculate_rho( obj_loc_t obj_loc, int id )
{
    if ( soption_call_or_put == CALL )
    {
        rho_rho = soption_T * srate_trade_KerT * sbs_delta_N_pd2;
    }
    else 
    {
        rho_rho = - soption_T * srate_trade_KerT * sbs_delta_N_md2;
    }
}

