// Copyright (c) Steve Evans 2009
// steve@topaz.myzen.co.uk
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE

// Please see the comment at the top of test_suite/gen/objects/addition_macros.c
//  to see what's in-scope.

#include <iostream>

#include "addition_wrapper.c"

using namespace std;

int calculate_addition( obj_loc_t obj_loc, int id )
{
    addition_output = numeric1_output + numeric2_output;

    return 1;
}

