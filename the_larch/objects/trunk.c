
// Please see the comment at the top of the_larch/gen/objects/trunk_macros.c
//  to see what's in-scope.

#include <iostream>
#include <math.h>

#include "trunk_wrapper.c"

using namespace std;

void calculate_trunk( obj_loc_t obj_loc, int id )
{
    if ( trunk_width == 0 ) 
    {
        trunk_width = trunk_start_width;
    }

    trunk_water_published = my_roots_water_published;

    double local_glucose_taken = my_crown_glucose_published * trunk_glucose_absorbed_coeff;
    trunk_glucose_published = my_crown_glucose_published - local_glucose_taken;
    trunk_glucose_store = trunk_glucose_store + local_glucose_taken;

    if ( trunk_glucose_store > trunk_glucose_per_square_millimeter )
    {
        int local_num_new_square_millimeters = (int)(( trunk_glucose_store - fmod( trunk_glucose_store, trunk_glucose_per_square_millimeter ) ) / trunk_glucose_per_square_millimeter );

        trunk_width = trunk_width + sqrt( local_num_new_square_millimeters );

        trunk_glucose_store = trunk_glucose_store - ( trunk_glucose_per_square_millimeter * local_num_new_square_millimeters );
    }
}

