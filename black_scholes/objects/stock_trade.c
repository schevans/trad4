
#include <iostream>
#include <math.h>

#include "stock_trade_wrapper.c"

using namespace std;

void calculate_stock_trade( obj_loc_t obj_loc, int id )
{
    DEBUG( "calculate_stock_trade( " << id << ")" )

    stock_trade_ln_SK = log( stock_feed_S / option_feed_K );

cout << "stock_feed_vv: " << stock_feed_vv << endl;
cout << "option_feed_T: " << option_feed_T << endl;

    stock_trade_vvT_2 = ( stock_feed_vv * option_feed_T ) / 2.0;

    stock_trade_vRtT = stock_feed_v * option_feed_RrT;
}

