
// Please see the comment at the top of the_larch/gen/objects/crown_macros.c
//  to see what's in-scope.

#include <iostream>
#include <math.h>

#include "crown_wrapper.c"

using namespace std;

void calculate_crown( obj_loc_t obj_loc, int id )
{
    if ( crown_num_leaves == 0 )
    {
        crown_num_leaves = crown_start_num_leaves;
    }

    crown_water_taken = my_trunk_water_published;

    double local_glucose_produced = ( ( crown_water_taken / crown_num_leaves ) + crown_light_absorbed_per_leaf + crown_co2_absorbed_per_leaf ) * crown_num_leaves;

    crown_glucose_published = local_glucose_produced * crown_glucose_published_coeff;

    crown_glucose_store = crown_glucose_store + ( local_glucose_produced - crown_glucose_published );

    if ( crown_glucose_store > crown_glucose_per_leaf )
    {
        int local_num_new_leaves = (int)(( crown_glucose_store - fmod( crown_glucose_store, crown_glucose_per_leaf ) ) / crown_glucose_per_leaf);

        crown_num_leaves = crown_num_leaves + local_num_new_leaves;
        crown_glucose_store = crown_glucose_store - ( crown_glucose_per_leaf * local_num_new_leaves );
    }

    crown_total_mass = crown_num_leaves * crown_mass_per_leaf;
}

