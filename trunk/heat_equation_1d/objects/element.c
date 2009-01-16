
// Please see the comment at the top of heat_equation_1d/gen/objects/element_macros.c
//  to see what's in-scope.

#include <iostream>
#include <math.h>

#include "element_wrapper.c"

using namespace std;

void calculate_element( obj_loc_t obj_loc, int id )
{
    if ( ! element_init ) 
    {
        element_init = 1;

        element_y = cos(2*element_x);
    }
    else
    {
        element_y = element_y + my_change_change;
    }

    if ( element_y < 0.0 ) 
        element_y = 0.0;
}
