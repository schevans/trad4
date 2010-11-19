// Copyright (c) Steve Evans 2010
// schevans@users.sourceforge.net
// This code is released under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

// Please see the comment at the top of hello_world/gen/objects/hello_world_macros.h
//  to see what's in-scope.

#include <iostream>

#include "hello_world_wrapper.c"

using namespace std;

int calculate_hello_world( obj_loc_t obj_loc, int id )
{
    cout << object_name(hello_world_hello) << " " << object_name(hello_world_world) << "!" << endl;

    return 1;
}

