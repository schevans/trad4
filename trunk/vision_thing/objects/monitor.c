
// GENERATED BY TRAD4 

// Please see the comment at the top of vision_thing/gen/objects/monitor_macros.h
//  to see what's in-scope.

#include <iostream>

#include "monitor_wrapper.c"

using namespace std;

int calculate_monitor( obj_loc_t obj_loc, int id )
{
    if ( ! object_init( id ) )
    {
        monitor_num_runs = 0;
        monitor_num_cycles_correct = 0;
    }

    int num_cucles_correct = 0;

    int local_all_correct = 1;

    for ( int i = 0 ; i < NUM_NEURONS ; i++ )
    {
        if ( neurons_correct(i) == 0 )  
        {
            local_all_correct = 0;
            monitor_num_cycles_correct = 0;
            break;
        }
    }

    if ( local_all_correct == 1 )
    {
        if ( monitor_num_cycles_correct >= NUM_IMAGES ) 
        {
            cout << "Converged in " << monitor_num_runs << " runs." << endl;
            cout << endl;

            exit(0);
        }

        monitor_num_cycles_correct++;
    }

    monitor_num_runs++;

    return 1;
}

