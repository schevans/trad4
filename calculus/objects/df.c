// Copyright (c) Steve Evans 2009
// steve@topaz.myzen.co.uk
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE

// Please see the comment at the top of calculus/gen/objects/df_macros.c
//  to see what's in-scope.

#include <iostream>
#include <math.h>

#include "df_wrapper.c"

using namespace std;

int calculate_df( obj_loc_t obj_loc, int id )
{
    double local_dx = f_up_x - f_down_x;

    df_df = ( f_up_y - f_down_y ) / local_dx;

    if ( fabs( df_df ) < 1.0e-10 )
        df_df = 0;

    df_dx = f_this_x;

    return 1;
}

