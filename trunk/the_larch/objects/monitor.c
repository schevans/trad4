
// Please see the comment at the top of the_larch/gen/objects/monitor_macros.c
//  to see what's in-scope.

#include <iostream>

#include "monitor_wrapper.c"

using namespace std;

void calculate_monitor( obj_loc_t obj_loc, int id )
{
    cout << "Glucose in trunk: " << my_trunk_glucose << endl;

    sleep(1);
}

