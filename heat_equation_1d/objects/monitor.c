
// Please see the comment at the top of heat_equation_1d/gen/objects/monitor_macros.c
//  to see what's in-scope.

#include <iostream>
#include <math.h>


#include "monitor_wrapper.c"
#include "change.h"

using namespace std;

void calculate_monitor( obj_loc_t obj_loc, int id )
{
    int converged = 1;

    for ( int i=0 ; i < NUM_CHANGES ; i++ )
    {
        if ( fabs( monitor_my_changes_change(i) ) > 1.0e-6 )
        {
            converged = 0; 
            break;
        }
    }

    if ( converged )
    {
        cout << "Converged in " << monitor_counter << " Steps" << endl;
        exit(0);
    }

    monitor_counter = monitor_counter + 1;
}

