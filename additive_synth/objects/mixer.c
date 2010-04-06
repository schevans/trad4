
// GENERATED BY TRAD4 

// Please see the comment at the top of additive_synth/gen/objects/mixer_macros.h
//  to see what's in-scope.

#include <iostream>

#include "sndfile.h"

#include "mixer_wrapper.c"


using namespace std;

int calculate_mixer( obj_loc_t obj_loc, int id )
{

    for ( int i = 0 ; i < SAMPLE_COUNT ; i++ )
    {
        for ( int j = 0 ; j < NUM_HARMONICS_PER_MIXER ; j++ )
        {
            mixer_wave[i] += samples_wave( j, i ) / NUM_HARMONICS_PER_MIXER;
        }
    }

    if ( mixer_write_wav_file )
    {
        SNDFILE *file;
        SF_INFO sfinfo;

        memset (&sfinfo, 0, sizeof (sfinfo));

        sfinfo.samplerate = SAMPLE_RATE;
        sfinfo.frames = SAMPLE_COUNT;
        sfinfo.channels = 1;
        sfinfo.format = (SF_FORMAT_WAV | SF_FORMAT_PCM_24);

        ostringstream filename;
        filename << object_name( id ) << ".wav";

        if (! (file = sf_open ( filename.str().c_str(), SFM_WRITE, &sfinfo)))
        {       
            printf ("Error : Not able to open output file.\n");
            return 0;
        }

        if (sf_write_int (file, mixer_wave, sfinfo.channels * SAMPLE_COUNT) != sfinfo.channels * SAMPLE_COUNT)
        {
            puts (sf_strerror (file));
        }

        sf_close(file);
    }

    return 1;
}

