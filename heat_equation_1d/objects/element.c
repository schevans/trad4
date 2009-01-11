
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

        element_value = cos(2*element_x);
    }
    else
    {
        element_value = element_value + my_change_change;
    }
}

