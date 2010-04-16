
// GENERATED BY TRAD4 

// Please see the comment at the top of additive_synth/gen/objects/harmonic_macros.h
//  to see what's in-scope.

#include <iostream>
#include <cmath>

#include "harmonic_wrapper.c"

#include "write_wav_file.c"

using namespace std;

double get_level( int id );

int calculate_harmonic( obj_loc_t obj_loc, int id )
{
    double level = get_level(id);

    for ( int i = 0 ; i <= SAMPLE_COUNT ; i++ ) 
    {
        harmonic_wave[i] = AMPLITUDE * sin ( BASE_FREQUENCY * 2 * i * PI * id ) * level;
    }

    if ( object_log_level(id) > NONE )
    {
        write_wav_file( harmonic_wave, object_name(id) );
    }

    return 1;
}

double get_level( int id )
{
    double level(0);

    int waveform = 1;

    if ( waveform == 1) // Pulse
    {
        level = 1.0;
    }
    else if ( waveform == 2 ) // Sawtooth
    {
        level = 1.0 / id;
    }
    else if ( waveform == 3 || waveform == 4 )
    {
        if ( id % 2 != 0 )
        {
            if ( waveform == 3 ) // Square
            {
                level = 1.0 / id;
            }
            else // Triangle
            {
                level = pow( -1.0, ( id - 1 ) / 2 ) * ( 1.0 / (id*id) );
            }
        }
        else
        {
            level = 0.0;
        }
    }

    return level;
}
