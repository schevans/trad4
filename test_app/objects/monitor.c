
// GENERATED BY TRAD4 

// Please see the comment at the top of test_app/gen/objects/monitor_macros.h
//  to see what's in-scope.

#include <iostream>

#include "monitor_wrapper.c"

using namespace std;

void calculate_monitor( obj_loc_t obj_loc, int id )
{
    T4_TEST( my_tier2_p_int, 14965 );
    T4_TEST( tier1s_int_out(0), 15003 );
}

