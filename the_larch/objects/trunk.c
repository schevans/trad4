
// Please see the comment at the top of the_larch/gen/objects/trunk_macros.c
//  to see what's in-scope.

#include <iostream>

#include "trunk_wrapper.c"

using namespace std;

void calculate_trunk( obj_loc_t obj_loc, int id )
{
    trunk_glucose = trunk_glucose + my_crown_glucose - my_roots_glucose_taken;
    trunk_water = trunk_water + my_roots_water - my_crown_water_taken;
}

