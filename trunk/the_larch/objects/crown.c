
// Please see the comment at the top of the_larch/gen/objects/crown_macros.c
//  to see what's in-scope.

#include <iostream>

#include "crown_wrapper.c"

using namespace std;

void calculate_crown( obj_loc_t obj_loc, int id )
{

    if ( crown_num_leaves == 0 )
    {
        crown_num_leaves = crown_start_num_leaves;
    }

    crown_water_taken = crown_water_absorbed_per_leaf * crown_num_leaves;

    crown_glucose = ( crown_water_absorbed_per_leaf + crown_light_absorbed_per_leaf + crown_co2_absorbed_per_leaf ) * crown_num_leaves;
}

