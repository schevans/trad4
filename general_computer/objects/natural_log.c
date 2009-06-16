// Copyright (c) Steve Evans 2009
// steve@topaz.myzen.co.uk
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE

// Please see the comment at the top of general_computer/gen/objects/natural_log_macros.c
//  to see what's in-scope.

#include <iostream>
#include <math.h>

#include "natural_log_wrapper.c"

using namespace std;

int calculate_natural_log( obj_loc_t obj_loc, int id )
{
    natural_log_output = log( numeric1_output );

    return 1;
}

