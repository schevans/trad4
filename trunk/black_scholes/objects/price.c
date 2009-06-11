
// Please see the comment at the top of black_scholes/gen/objects/price_macros.c
//  to see what's in-scope.

#include <iostream>

#include "price_wrapper.c"

using namespace std;

int calculate_price( obj_loc_t obj_loc, int id )
{
    if ( soption_call_or_put == CALL )
    {
        price_price = ( sstock_S * sbs_delta_N_pd1 ) - ( srate_trade_KerT * sbs_delta_N_pd2 );
    }
    else
    {
        price_price = ( srate_trade_KerT * sbs_delta_N_pd2  ) - ( sstock_S * sbs_delta_N_md1 );
    }

    return 1;
}

