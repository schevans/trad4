
// Please see the comment at the top of the_larch/gen/objects/monitor_macros.c
//  to see what's in-scope.

#include <iostream>

#include "monitor_wrapper.c"

using namespace std;

void calculate_monitor( obj_loc_t obj_loc, int id )
{
    cout << "Trunk glucose: " << my_trunk_glucose << ", trunk water: " << my_trunk_water << endl;

    cout << "crown_glucose_published: " << my_crown_glucose_published << ", crown_glucose_store: " << my_crown_glucose_store << endl;

    cout << "my_crown_num_leaves: " << my_crown_num_leaves << endl;

    sleep(1);
}

