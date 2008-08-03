
// Please see the comment at the top of black_scholes/gen/objects/price_macros.c
//  to see what's in-scope.

#include <iostream>

#include "price_wrapper.c"

using namespace std;

void calculate_price( obj_loc_t obj_loc, int id )
{
    DEBUG( "calculate_price( " << id << " )" )

    if ( option_call_or_put == CALL )
    {
        price_price = ( stock_S * bs_delta_N_pd1 ) - ( rho_rho );
    }
    else
    {
        price_price = ( rho_rho ) - ( stock_S * bs_delta_N_md1 );
    }
}

