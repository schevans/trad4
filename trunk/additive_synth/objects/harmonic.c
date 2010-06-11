// Copyright (c) Steve Evans 2010
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $APP_ROOT/LICENCE

// Please see the comment at the top of additive_synth/gen/objects/harmonic_macros.h
//  to see what's in-scope.

#include <iostream>
#include <cmath>

#include "harmonic_wrapper.c"

#include "write_wav_file.c"

using namespace std;

int calculate_harmonic( obj_loc_t obj_loc, int id )
{
    harmonic_is_active = 1;
    double level = waveform_amplitude[id-1];
    double frequency = waveform_base_frequency * id;

    if ( frequency > NYQUIST_FREQUENCY )
    {
        cout << "Warning: Frequency of " << object_name(id) << " (" << frequency << "Hz) exceeds Nyquist frequency (" << NYQUIST_FREQUENCY << "Hz). Ignoring harmonic." << endl;

        harmonic_is_active = 0;
    }

    if ( level == 0.0 )
    {
        harmonic_is_active = 0;
    }

    if ( harmonic_is_active )
    {
        for ( int i = 0 ; i < SAMPLE_COUNT ; i++ ) 
        {
            harmonic_wave[i] = AMPLITUDE * sin ( ( frequency * 2 * i * PI ) / (double)SAMPLE_RATE ) * waveform_amplitude[id-1];
        }
    }

    if ( object_log_level(id) > NONE )
    {
        write_wav_file( harmonic_wave, object_name(id) );
    }

    return 1;
}

