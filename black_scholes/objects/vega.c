
#include <iostream>

#include "vega_wrapper.c"

using namespace std;

void calculate_vega( obj_loc_t obj_loc, int id )
{
    DEBUG( "calculate_vega( " << id << ")" )

    vega_vega = stock_feed_S * bs_delta_N_pd1 * option_feed_RrT;

    cout << "vega: " << vega_vega << endl;
}

