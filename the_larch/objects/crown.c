
// Please see the comment at the top of the_larch/gen/objects/crown_macros.c
//  to see what's in-scope.

#include <iostream>

#include "crown_wrapper.c"

using namespace std;

void calculate_crown( obj_loc_t obj_loc, int id )
{
    crown_water_taken = 0.5;
    crown_glucose = crown_co2 + crown_water_taken + crown_light;
}

