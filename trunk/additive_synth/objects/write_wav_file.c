
#include "sndfile.h"


void write_wav_file( int* wave, std::string filename )
{
    SNDFILE *file;
    SF_INFO sfinfo;

    memset (&sfinfo, 0, sizeof (sfinfo));

    sfinfo.samplerate = SAMPLE_RATE;
    sfinfo.frames = SAMPLE_COUNT;
    sfinfo.channels = 1;
    sfinfo.format = (SF_FORMAT_WAV | SF_FORMAT_PCM_24);

    ostringstream oss;
    oss << filename << ".wav";

    if (! (file = sf_open ( oss.str().c_str(), SFM_WRITE, &sfinfo)))
    {
        printf ("Error : Not able to open output file.\n");
        exit(0);
    }

    if (sf_write_int (file, wave, sfinfo.channels * SAMPLE_COUNT) != sfinfo.channels * SAMPLE_COUNT)
    {
        puts (sf_strerror (file));
    }

    sf_close(file);

}

