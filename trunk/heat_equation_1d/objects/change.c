// Copyright (c) Steve Evans 2009
// steve@topaz.myzen.co.uk
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE

// Please see the comment at the top of heat_equation_1d/gen/objects/change_macros.c
//  to see what's in-scope.

#include <iostream>
#include <math.h>

#include "change_wrapper.c"

using namespace std;

void calculate_change( obj_loc_t obj_loc, int id )
{
    double local_2dx = up_element_x - down_element_x;
    double local_down_element_y = down_element_y;
    double local_up_element_y = up_element_y;

    if ( this_element_element_type == START )
    {
        local_2dx = 2 * ( up_element_x - this_element_x );
        local_down_element_y = my_data_server_alpha;
    }
    else if ( this_element_element_type == END )
    {
        local_2dx = 2 * ( this_element_x - down_element_x );
        local_up_element_y = my_data_server_beta;
    }
        
    change_change = my_data_server_k * ( local_down_element_y - 2*this_element_y + local_up_element_y ) / local_2dx;;
}

