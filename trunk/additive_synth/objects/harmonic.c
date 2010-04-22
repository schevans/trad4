
// GENERATED BY TRAD4 

// Please see the comment at the top of additive_synth/gen/objects/harmonic_macros.h
//  to see what's in-scope.

#include <iostream>
#include <cmath>

#include "harmonic_wrapper.c"

#include "write_wav_file.c"

using namespace std;

double get_level( obj_loc_t obj_loc, int id );

int calculate_harmonic( obj_loc_t obj_loc, int id )
{
    harmonic_level = get_level( obj_loc, id );
    double frequency = BASE_FREQUENCY * id;

    if ( frequency > NYQUIST_FREQUENCY )
    {
        cout << "Warning: Frequency of " << object_name(id) << " (" << frequency << "Hz) exceeds Nyquist frequency (" << NYQUIST_FREQUENCY << "Hz). Ignoring harmonic." << endl;

        harmonic_level = 0.0;
    }
    else
    { 
        for ( int i = 0 ; i < SAMPLE_COUNT ; i++ ) 
        {
            harmonic_wave[i] = AMPLITUDE * sin ( ( frequency * 2 * i * PI ) / (double)SAMPLE_RATE ) * harmonic_level;
        }
    }

    if ( object_log_level(id) > NONE )
    {
        write_wav_file( harmonic_wave, object_name(id) );
    }

    return 1;
}

double get_level( obj_loc_t obj_loc, int id )
{
    double level(0);

    if ( harmonic_waveform == SINE )
    {
        if ( id == 1 )
        {
            level = 1.0;
        }
    }
    else if ( harmonic_waveform == PULSE )
    {
        level = 1.0;
    }
    else if ( harmonic_waveform == SAWTOOTH )
    {
        level = 1.0 / id;
    }
    else if ( harmonic_waveform == SQUARE || harmonic_waveform == TRIANGLE )
    {
        if ( id % 2 != 0 )
        {
            if ( harmonic_waveform == SQUARE )
            {
                level = 1.0 / id;
            }
            else // TRIANGLE
            {
                level = pow( -1.0, ( id - 1 ) / 2 ) * ( 1.0 / (id*id) );
            }
        }
        else
        {
            level = 0.0;
        }
    }
    else if ( harmonic_waveform == HAMMOND )
    {
        int drawbar[10] = { 8,8,8,0,0,0,0,0,0,0 }; 

        // Note the strange Hammond mapping of drawbars to harmonics below.
        switch( id )
        {
            case 1:
                level = drawbar[0] / 8;
                break;

            case 3:                         
                level = drawbar[1] / 8;
                break;

            case 2:
                level = drawbar[2] / 8;    
                break;

            case 4:
                level = drawbar[3] / 8;     
                break;

            case 6:
                level = drawbar[4] / 8;   
                break;

            case 8:
                level = drawbar[5] / 8;  
                break;

            case 10:
                level = drawbar[7] / 8; 
                break;

            case 12:
                level = drawbar[8] / 8;
                break;

            case 16:
                level = drawbar[9] / 8;
                break;

            default:
                level = 0.0;

        }

    }
    else
    {
        cerr << "Unknown waveform_enum " << harmonic_waveform << " in harmonic id " << id << "." << endl;
    } 

    return level;
}
