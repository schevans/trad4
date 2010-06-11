
// GENERATED BY TRAD4 

// Please see the comment at the top of fourier_transform/gen/objects/source_macros.h
//  to see what's in-scope.

#include <iostream>

#include "sndfile.h"

#include "source_wrapper.c"

using namespace std;

int calculate_source( obj_loc_t obj_loc, int id )
{
    SNDFILE *file;

    SF_INFO sfinfo;

    memset (&sfinfo, 0, sizeof (sfinfo));

    sfinfo.format = 0;

    string infile = "./source.wav";

    if (! (file = sf_open ( infile.c_str(), SFM_READ, &sfinfo)))
    {
        printf ("Error : Not able to open input file %s.\n", infile.c_str());
        exit(0);
    }

    if (sf_read_int (file, source_wave, SAMPLE_COUNT) != SAMPLE_COUNT)
    {
        puts (sf_strerror (file));
    }

    sf_close(file);

    return 1;
}

