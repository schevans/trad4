
// GENERATED BY TRAD4 

// Please see the comment at the top of test_app/gen/objects/tier3_macros.h
//  to see what's in-scope.

#include <iostream>

#include "tier3_wrapper.c"

using namespace std;

int calculate_tier3( obj_loc_t obj_loc, int id )
{
    T4_TEST( my_tier2_p_int, 14965 );
    T4_TEST( my_tier1_int_out - my_tier2_p_int, 38 );
    T4_TEST( my_tier1_double_array[ 2 ] * my_tier1_double_array[ 3 ], 12.9996 );

    return 1;
}

