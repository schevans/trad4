
// Please see the comment at the top of the_larch/gen/objects/roots_macros.c
//  to see what's in-scope.

#include <iostream>
#include <math.h>

#include "roots_wrapper.c"

using namespace std;

void calculate_roots( obj_loc_t obj_loc, int id )
{
    if ( roots_num_rootlets == 0 )
    {
        roots_num_rootlets = roots_start_num_rootlets;
    }

    roots_water_published = roots_water_absorbed_per_rootlet * roots_num_rootlets;

    roots_glucose_taken = my_trunk_glucose;

    roots_glucose_store = roots_glucose_store + roots_glucose_taken;

    if ( roots_glucose_store > roots_glucose_per_rootlet )
    {
        int local_num_new_rootlets = (int)(( roots_glucose_store - fmod( roots_glucose_store, roots_glucose_per_rootlet ) ) / roots_glucose_per_rootlet );

        roots_num_rootlets = roots_num_rootlets + local_num_new_rootlets;

        roots_glucose_store = roots_glucose_store - ( roots_glucose_per_rootlet * local_num_new_rootlets );
    }
}

