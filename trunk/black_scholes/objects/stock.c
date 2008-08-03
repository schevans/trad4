
// Please see the comment at the top of black_scholes/gen/objects/stock_macros.c
//  to see what's in-scope.

#include <iostream>

#include "stock_wrapper.c"

using namespace std;

void calculate_stock( obj_loc_t obj_loc, int id )
{
    DEBUG( "calculate_stock( " << id << " )" )

    stock_vv = stock_v * stock_v;

cout << "stock_v: " << stock_v << endl;
cout << "stock_vv: " << stock_vv << endl;

}

