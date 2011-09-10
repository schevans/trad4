// Copyright (c) Steve Evans 2009
// schevans@users.sourceforge.net
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE
//
// This application is based on the ISDA CDS Standard Model (version 1.7),  
// developed and supported in collaboration with Markit Group Ltd.

// Please see the comment at the top of jpm_cds/gen/objects/leg_macros.h
//  to see what's in-scope.

#include <iostream>

#include "leg_wrapper.c"

using namespace std;

int calculate_leg( obj_loc_t obj_loc, long id )
{
    // Does nothing - pure virtual base type

    return 1;
}

