// Copyright (c) Steve Evans 2007 
// steve@topaz.myzen.co.uk 
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE 
//  

// GENERATED BY TRAD4 

// Please see the comment at the top of bond_risk/gen/objects/repo_book_macros.h
//  to see what's in-scope.

#include <iostream>

#include "repo_book_wrapper.c"

using namespace std;

int calculate_repo_book( obj_loc_t obj_loc, int id )
{
    repo_book_margin=0;
    repo_book_mtm_pnl=0;

    for ( int i=0 ; i < MAX_TRADES_PER_BOOK ; i++ )
    {
        if ( repo_book_repo_trades[i] )
        {
            repo_book_margin += repo_trades_margin(i);
            repo_book_mtm_pnl += repo_trades_mtm_pnl(i);
        }
    }    

cout << "repo_book_mtm_pnl: " << repo_book_mtm_pnl << endl;

    return 1;
}

