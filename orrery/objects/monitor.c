
// GENERATED BY TRAD4 

// Please see the comment at the top of orrery/gen/objects/monitor_macros.h
//  to see what's in-scope.

#include <iostream>

#include "monitor_wrapper.c"

using namespace std;

int calculate_monitor( obj_loc_t obj_loc, int id )
{
    if ( bodies_counter(0) >= MAX_RUNS-1 )
    {
        exit(0);
    }

    return 1;
}

