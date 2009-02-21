
// Please see the comment at the top of calculus/gen/objects/monitor_macros.c
//  to see what's in-scope.

#include <iostream>

#include "monitor_wrapper.c"

using namespace std;

void calculate_monitor( obj_loc_t obj_loc, int id )
{

    cout << "x,";

    for ( int i=0 ; i < NUM_NODES ; i++ )
    {
        cout << monitor_my_f_x( i ) << ",";
    }

    cout << endl;

    cout << "y,";

    for ( int i=0 ; i < NUM_NODES ; i++ )
    {
        cout << monitor_my_f_y( i ) << ",";
    }

    cout << endl;

    cout << "dy,";

    for ( int i=0 ; i < NUM_NODES ; i++ )
    {
        cout << monitor_my_df_df( i ) << ",";
    }

    cout << endl;

    cout << "d2y,";

    for ( int i=0 ; i < NUM_NODES ; i++ )
    {
        cout << monitor_my_d2f_d2f( i ) << ",";
    }

    cout << endl;
}

