
#include <iostream>

#include "rho_wrapper.c"

using namespace std;

void calculate_rho( obj_loc_t obj_loc, int id )
{
    DEBUG( "calculate_rho( " << id << ")" )

    if ( option_feed_call_or_put == CALL )
    {
        rho_rho = rate_trade_KerT * option_feed_T * bs_delta_N_pd2;
    }
    else
    {
        rho_rho = - rate_trade_KerT * option_feed_T * bs_delta_N_md2;
    }

    cout << "rho: " << rho_rho << endl;
}

