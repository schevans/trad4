
// GENERATED BY TRAD4 

// Please see the comment at the top of additive_synth/gen/objects/harmonic_macros.h
//  to see what's in-scope.

#include <iostream>
#include <cmath>

#include "harmonic_wrapper.c"

#define         LEFT_FREQ                       (344.0 / SAMPLE_RATE)
#define         RIGHT_FREQ                      (466.0 / SAMPLE_RATE)


using namespace std;

int calculate_harmonic( obj_loc_t obj_loc, int id )
{
    for ( int i = 0 ; i <= SAMPLE_COUNT ; i++ ) 
    {
        if ( id == 1 )
        {
            harmonic_wave[i] = AMPLITUDE * sin ( LEFT_FREQ * 2 * i * PI );
        }
        else
        {
            harmonic_wave[i] = AMPLITUDE * sin ( RIGHT_FREQ * 2 * i * PI );

        }
    }

    return 1;
}
