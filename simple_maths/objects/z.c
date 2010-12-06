// Copyright (c) Steve Evans 2010 
// schevans@users.sourceforge.net 
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE 
//  

// Please see the comment at the top of simple_maths/gen/objects/z_macros.h
//  to see what's in-scope.

#include <iostream>

#include "z_wrapper.c"

using namespace std;

int calculate_z( obj_loc_t obj_loc, int id )
{
    z_out = x_out * y_out;

    cout << "z_out: " << z_out << endl;

    return 1;
}

