
// Please see the comment at the top of calculus/gen/objects/f_macros.c
//  to see what's in-scope.

#include <iostream>
#include <math.h>

#include "f_wrapper.c"

using namespace std;

void calculate_f( obj_loc_t obj_loc, int id )
{
    f_x = (id*1.0) / NUM_NODES;

    // Change me.
    f_y = sin(5*f_x);

}

