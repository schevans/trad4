
// Please see the comment at the top of black_scholes/gen/objects/price_macros.c
//  to see what's in-scope.

#include <iostream>

#include "price_wrapper.c"

using namespace std;

int calculate_price( obj_loc_t obj_loc, int id )
{
    if ( option_call_or_put == CALL )
    {
        price_price = ( stock_S * bs_delta_N_pd1 ) - ( rate_trade_KerT * bs_delta_N_pd2 );
    }
    else
    {
        price_price = ( rate_trade_KerT * bs_delta_N_pd2  ) - ( stock_S * bs_delta_N_md1 );
    }

    return 1;
}

