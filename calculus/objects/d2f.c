// Copyright (c) Steve Evans 2009
// steve@topaz.myzen.co.uk
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE

// Please see the comment at the top of calculus/gen/objects/d2f_macros.c
//  to see what's in-scope.

#include <iostream>
#include <math.h>

#include "d2f_wrapper.c"

using namespace std;

void calculate_d2f( obj_loc_t obj_loc, int id )
{

    double local_d2x = df_up_dx - df_down_dx;

    d2f_d2f = ( df_up_df - df_down_df ) / local_d2x;

    if ( fabs( d2f_d2f ) < 1.0e-10 )
        d2f_d2f = 0;
}

