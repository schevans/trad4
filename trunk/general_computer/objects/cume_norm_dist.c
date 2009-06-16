// Copyright (c) Steve Evans 2009
// steve@topaz.myzen.co.uk
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE

// Please see the comment at the top of general_computer/gen/objects/cume_norm_dist_macros.c
//  to see what's in-scope.

#include <iostream>
#include <math.h>


#include "cume_norm_dist_wrapper.c"

using namespace std;

int calculate_cume_norm_dist( obj_loc_t obj_loc, int id )
{

    double x = numeric1_output;

    const double b1 =  0.319381530;
    const double b2 = -0.356563782;
    const double b3 =  1.781477937;
    const double b4 = -1.821255978;
    const double b5 =  1.330274429;
    const double p  =  0.2316419;
    const double c  =  0.39894228;

    if ( x >= 0.0 ) 
    {

        double t = 1.0 / ( 1.0 + p * x );
        cume_norm_dist_output = (1.0 - c * exp( -x * x / 2.0 ) * t * ( t *( t * ( t * ( t * b5 + b4 ) + b3 ) + b2 ) + b1 ));
    }
    else 
    {
    
        double t = 1.0 / ( 1.0 - p * x );
        cume_norm_dist_output = ( c * exp( -x * x / 2.0 ) * t * ( t *( t * ( t * ( t * b5 + b4 ) + b3 ) + b2 ) + b1 ));
    }


    return 1;
}

