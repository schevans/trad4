
// Please see the comment at the top of black_scholes/gen/objects/risk_free_rate_macros.c
//  to see what's in-scope.

#include <iostream>

#include "risk_free_rate_wrapper.c"

using namespace std;

int calculate_risk_free_rate( obj_loc_t obj_loc, int id )
{
    // Does nothing.

    // Validate.
    if ( risk_free_rate_r < 0 )
        return 0;
    else
        return 1;
}

