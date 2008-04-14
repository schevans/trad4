
#include <iostream>

#include "stock_feed_wrapper.c"

using namespace std;

void* calculate_stock_feed( int id )
{
    DEBUG( "calculate_stock_feed( " << id << ")" )

    stock_feed_vv = stock_feed_v * stock_feed_v;

cout << "stock_feed_v: " << stock_feed_v << endl;
cout << "stock_feed_vv: " << stock_feed_vv << endl;
}

