// Copyright (c) Steve Evans 2009
// steve@topaz.myzen.co.uk
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE

// Please see the comment at the top of general_computer/gen/objects/multiplication_macros.c
//  to see what's in-scope.

#include <iostream>

#include "multiplication_wrapper.c"

using namespace std;

void calculate_multiplication( obj_loc_t obj_loc, int id )
{
    multiplication_output = numeric1_output * numeric2_output;
}

