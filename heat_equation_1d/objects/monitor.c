
// Please see the comment at the top of heat_equation_1d/gen/objects/monitor_macros.c
//  to see what's in-scope.

#include <iostream>
#include <math.h>


#include "monitor_wrapper.c"

using namespace std;

void print_data( obj_loc_t obj_loc, int id );

void calculate_monitor( obj_loc_t obj_loc, int id )
{
    int converged = 1;
    int diverged = 0;

    double converged_limit =  1.0e-6;
    double diverged_limit =  1.0;

    for ( int i=0 ; i < NUM_NODES ; i++ )
    {
        if ( fabs( monitor_my_changes_change(i) ) > diverged_limit )
        {
            diverged = 1;
            break;
        }

        if ( converged && fabs( monitor_my_changes_change(i) ) > converged_limit )
        {
            converged = 0; 
        }
    }

    if ( converged )
    {

        print_data( obj_loc, id );
        cout << "Converged in " << monitor_counter << " Steps" << endl;

        exit(0);
    }

    if ( diverged )
    {
        print_data( obj_loc, id );
        cout << "Diverged in " << monitor_counter << " Steps" << endl;
        exit(0);
    }

    monitor_counter = monitor_counter + 1;
}

void print_data( obj_loc_t obj_loc, int id )
{
    cout << "x";

    for ( int i=0 ; i < NUM_NODES ; i++ )
    {
        cout << "," << monitor_my_elements_x(i);
    }

    cout << endl << "y";

    for ( int i=0 ; i < NUM_NODES ; i++ )
    {
        cout << "," << monitor_my_elements_y(i);
    }

    cout << endl << "change";

    for ( int i=0 ; i < NUM_NODES ; i++ )
    {
        cout << "," << monitor_my_changes_change(i);
    }

    cout << endl;
}



