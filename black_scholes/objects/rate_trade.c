
#include <iostream>
#include <math.h>

#include "rate_trade_wrapper.c"

using namespace std;

void* calculate_rate_trade( int id )
{
    DEBUG( "calculate_rate_trade( " << id << ")" )

    rate_trade_rT = risk_free_rate_feed_r * option_feed_T;

    rate_trade_KerT = option_feed_T * exp( - rate_trade_rT );

    rate_trade_rKerT = 0.0; //TODO 
}

