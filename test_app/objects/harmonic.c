
// GENERATED BY TRAD4 

// Please see the comment at the top of test_app/gen/objects/harmonic_macros.h
//  to see what's in-scope.

#include <iostream>

#include "harmonic_wrapper.c"

using namespace std;

int calculate_harmonic( obj_loc_t obj_loc, long id )
{
    harmonic_level = harmonic_factor;

    for ( int i = 0 ; i < SAMPLE_COUNT ; i++ )
    {
        harmonic_wave[i] = i * harmonic_level;
    }

    return 1;
}

