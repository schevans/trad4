// Copyright (c) Steve Evans 2010
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $APP_ROOT/LICENCE

// Please see the comment at the top of additive_synth/gen/objects/mixer_macros.h
//  to see what's in-scope.

#include <iostream>

#include "mixer_wrapper.c"

#include "write_wav_file.c"

using namespace std;

int calculate_mixer( obj_loc_t obj_loc, int id )
{
    mixer_level = 0.0;

    for ( int j = 0 ; j < NUM_HARMONICS_PER_MIXER ; j++ )
    {
        if ( samples_level(j) != 0.0 )
        {
            for ( int i = 0 ; i < SAMPLE_COUNT ; i++ )
            {
                mixer_wave[i] += samples_wave( j, i ) / (double)NUM_HARMONICS_PER_MIXER;
            }

            mixer_level += samples_level(j) / (double)NUM_HARMONICS_PER_MIXER;
        }
    }

    if ( object_log_level(id) > NONE )
    {
        write_wav_file( mixer_wave, object_name(id) );
    }

    return 1;
}

