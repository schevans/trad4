
// Please see the comment at the top of calculus/gen/objects/d2f_macros.c
//  to see what's in-scope.

#include <iostream>
#include <math.h>

#include "d2f_wrapper.c"

using namespace std;

void calculate_d2f( obj_loc_t obj_loc, int id )
{
    d2f_d2f = ( df1_df - df2_df ) / df1_dx;

    if ( fabs( d2f_d2f ) < 1.0e-10 )
        d2f_d2f = 0;

}

