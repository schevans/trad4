// Copyright (c) Steve Evans 2009
// steve@topaz.myzen.co.uk
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE

// Please see the comment at the top of test_suite/gen/objects/numeric_macros.c
//  to see what's in-scope.

#include <iostream>

#include "numeric_wrapper.c"

using namespace std;

int calculate_numeric( obj_loc_t obj_loc, int id )
{
    cout << "Warning: calculate_numeric is being called. Doing nothing" << endl;

    return 1;
}

