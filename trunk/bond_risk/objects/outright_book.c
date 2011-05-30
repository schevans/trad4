// Copyright (c) Steve Evans 2010
// schevans@users.sourceforge.net
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE
//  

// Please see the comment at the top of bond_risk/gen/objects/outright_book_macros.h
//  to see what's in-scope.

#include <iostream>

#include "outright_book_wrapper.c"

using namespace std;

int calculate_outright_book( obj_loc_t obj_loc, long id )
{
    // Reset the accumulators
    outright_book_pv=0;
    outright_book_pv_01=0;
    outright_book_pnl=0;    

    // Note the counter from 0 to < MAX_TRADES_PER_BOOK
    for ( int i=0 ; i < MAX_TRADES_PER_BOOK ; i++ )
    {
        // Note the test to see if this objects exists before de-referencing
        if ( outright_book_outright_trades[i] )
        {
            outright_book_pv += outright_trades_pv(i);
            outright_book_pv_01 += outright_trades_pv_01(i);
            outright_book_pnl += outright_trades_pnl(i);
        }
    }

    return 1;
}

