
#include <iostream>

#include "price_wrapper.c"

using namespace std;

void* calculate_price( int id )
{
    DEBUG( "calculate_price( " << id << ")" )

    if ( option_feed_call_or_put == CALL )
    {
        price_price = stock_feed_S * bs_delta_N_pd1 - kertn_d2_KerTN_pd2;
    }
    else
    {
        price_price = kertn_d2_KerTN_md2 - stock_feed_S * bs_delta_N_md1;
    }

    cout << "price_price: " << price_price << endl;
}

