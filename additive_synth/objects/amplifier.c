// Copyright (c) Steve Evans 2010
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $APP_ROOT/LICENCE

// Please see the comment at the top of additive_synth/gen/objects/amplifier_macros.h
//  to see what's in-scope.

#include <iostream>

#include "amplifier_wrapper.c"
#include "write_wav_file.c"

using namespace std;

int calculate_amplifier( obj_loc_t obj_loc, int id )
{
    double max_level(0.0);

    for ( int i = 0 ; i < SAMPLE_COUNT ; i++ )
    {
        if ( fabs(sample_wave[i]) > max_level )
        {
            max_level = fabs(sample_wave[i]);
        }
    }

    double level_coeff = MAX_VOLUME / (max_level / AMPLITUDE);

    for ( int i = 0 ; i < SAMPLE_COUNT ; i++ )
    {
        sample_wave[i] *= level_coeff;
    }

    write_wav_file( sample_wave, "output" );
    
    return 1;
}

