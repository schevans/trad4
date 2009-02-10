
// Please see the comment at the top of general_computer/gen/objects/square_root_macros.c
//  to see what's in-scope.

#include <iostream>
#include <math.h>

#include "square_root_wrapper.c"

using namespace std;

void calculate_square_root( obj_loc_t obj_loc, int id )
{
    square_root_output = sqrt( numeric1_output );
}

