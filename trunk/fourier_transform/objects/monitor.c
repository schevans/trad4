
// GENERATED BY TRAD4 

// Please see the comment at the top of fourier_transform/gen/objects/monitor_macros.h
//  to see what's in-scope.

#include <iostream>
#include <fstream>

#include "monitor_wrapper.c"

using namespace std;

int calculate_monitor( obj_loc_t obj_loc, int id )
{
    ofstream outfile( "test.txt" );

    for ( int i=0 ; i < NUM_CORRELATORS ; i++ )
    {
        outfile << correlators_amplitude(i) << endl;
    }

    outfile.close();

    return 1;
}
