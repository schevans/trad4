
// Please see the comment at the top of black_scholes/gen/objects/option_macros.c
//  to see what's in-scope.

#include <iostream>
#include <math.h>

#include "option_wrapper.c"

using namespace std;

void calculate_option( obj_loc_t obj_loc, int id )
{
    DEBUG( "calculate_option( " << id << " )" )

    option_RtT = sqrt( option_T );
}

