// Copyright (c) Steve Evans 2009
// steve@topaz.myzen.co.uk
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE

// Please see the comment at the top of heat_equation_1d/gen/objects/element_macros.c
//  to see what's in-scope.

#include <iostream>
#include <math.h>

#include "element_wrapper.c"

using namespace std;

int calculate_element( obj_loc_t obj_loc, int id )
{
    if ( ! object_init(id) ) 
    {
//      Use for id = 0.1 - 1.0
        element_x = (id*1.0)/NUM_NODES;
        element_y = cos( 2*(element_x) );

//      Use for id = 1 - 10
//        element_x = id;
//        element_y = cos( 2*((element_x*1.0)/(NUM_NODES)) );
    }
    else
    {
        element_y = element_y + change_change;
    }

    if ( element_y < 0.0 ) 
        element_y = 0.0;

    return 1;
}

