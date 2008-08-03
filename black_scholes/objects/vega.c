
// Please see the comment at the top of black_scholes/gen/objects/vega_macros.c
//  to see what's in-scope.

#include <iostream>

#include "vega_wrapper.c"

using namespace std;

void calculate_vega( obj_loc_t obj_loc, int id )
{
    DEBUG( "calculate_vega( " << id << " )" )

    vega_vega = stock_S * bs_delta_N_pd1 * option_RtT;

    cout << "vega: " << vega_vega << endl;

}

