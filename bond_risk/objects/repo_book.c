// Copyright (c) Steve Evans 2010
// schevans@users.sourceforge.net
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE
//  

// Please see the comment at the top of bond_risk/gen/objects/repo_book_macros.h
//  to see what's in-scope.

#include <iostream>

#include "repo_book_wrapper.c"

using namespace std;

int calculate_repo_book( obj_loc_t obj_loc, int id )
{
    // Reset the accumulators
    repo_book_margin=0;
    repo_book_mtm_pnl=0;

    // Note the counter from 0 to < MAX_TRADES_PER_BOOK
    for ( int i=0 ; i < MAX_TRADES_PER_BOOK ; i++ )
    {
        // Note the test to see if this objects exists before de-referencing
        if ( repo_book_repo_trades[i] )
        {
            repo_book_margin += repo_trades_margin(i);
            repo_book_mtm_pnl += repo_trades_mtm_pnl(i);
        }
    }    

    return 1;
}

