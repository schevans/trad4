
// Please see the comment at the top of calculus/gen/objects/df_macros.c
//  to see what's in-scope.

#include <iostream>
#include <math.h>

#include "df_wrapper.c"

using namespace std;

void calculate_df( obj_loc_t obj_loc, int id )
{
    df_dx = f1_x - f2_x;
    df_df = ( f1_y - f2_y ) / df_dx;

    if ( fabs( df_df ) < 1.0e-10 )
        df_df = 0;
}

