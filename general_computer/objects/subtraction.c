// Copyright (c) Steve Evans 2010
// schevans@users.sourceforge.net
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE


// Please see the comment at the top of general_computer/gen/objects/subtraction_macros.c
//  to see what's in-scope.

#include <iostream>

#include "subtraction_wrapper.c"

using namespace std;

int calculate_subtraction( obj_loc_t obj_loc, int id )
{
    subtraction_output = numeric1_output - numeric2_output;

    return 1;
}

