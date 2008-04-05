
#include <iostream>
#include <math.h>

#include "stock_trade_wrapper.c"

using namespace std;

void* calculate_stock_trade( int id )
{
    DEBUG( "calculate_stock_trade( " << id << ")" )

    stock_trade_ln_SK = log( stock_feed_S / option_feed_K );

    stock_trade_vvT_2 = ( stock_feed_vv * option_feed_T ) / 2.0;

    stock_trade_vRtT = stock_feed_v * sqrt( option_feed_T );
}

