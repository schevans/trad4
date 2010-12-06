// Copyright (c) Steve Evans 2010
// schevans@users.sourceforge.net
// This code is released under the BSD licence. For details see $INSTANCE_ROOT/LICENCE
//

// Please see the comment at the top of bond_risk/gen/objects/ir_curve_macros.h
//  to see what's in-scope.

#include <iostream>
#include <math.h>

#include "ir_curve_wrapper.c"

using namespace std;

int calculate_ir_curve( obj_loc_t obj_loc, int id )
{
    int current_period_start(0);
    int current_period_end(0);

    double gradient(0);
    double y_intercept(0);

    // Interpolate the IR first..
    for ( int indx = 0; indx < NUM_INPUT_RATES - 1 ; indx++)
    {
        current_period_start = ir_curve_input_rates_days_forward(indx);
        current_period_end = ir_curve_input_rates_days_forward(indx+1);

        gradient = ((  ir_curve_input_rates_value(indx) -  ir_curve_input_rates_value(indx+1) ) / (  ir_curve_input_rates_days_forward(indx) -  ir_curve_input_rates_days_forward(indx+1) ) );
        y_intercept = ir_curve_input_rates_value(indx) - gradient * ir_curve_input_rates_days_forward(indx);

/*
        cout << "current_period_start: " << current_period_start 
            << ", current_period_end: " << current_period_end 
            << ", ir_curve_input_rates_value(indx): " << ir_curve_input_rates_value(indx)
            << ", ir_curve_input_rates_value(indx+1): " << ir_curve_input_rates_value(indx+1)
            << ", gradient: " << gradient 
            << ", y_intercept: " << y_intercept << endl;
*/
        for ( int i = current_period_start ; i < current_period_end ; i++ )
        {
            //cout << "\tDate " << i << " index  " << i << " rate: " <<(  i*gradient + y_intercept ) << endl;
            ir_curve_interest_rate_interpol[i] = ( i*gradient + y_intercept );
        }

    }
    
    // Then calculate the discount rates..
    double num_years(0);

    for ( int i = 0 ; i < NUM_FORWARD_DAYS ; i++ )
    {
        num_years = i / YEAR_BASIS;

        ir_curve_discount_rate[i] = exp( -ir_curve_interest_rate_interpol[i] * num_years );
        ir_curve_discount_rate_p01[i] = exp( -(ir_curve_interest_rate_interpol[i] +0.0001) * num_years );
        ir_curve_discount_rate_m01[i] = exp( -(ir_curve_interest_rate_interpol[i] -0.0001) * num_years );

/*
        cout << "ir_curve_discount_rate[" << i << "]: " << ir_curve_discount_rate[i]
            << ", ir_curve_discount_rate_p01[" << i << "]: " << ir_curve_discount_rate_p01[i]
            << ", ir_curve_discount_rate_m01[" << i << "]: " << ir_curve_discount_rate_m01[i]
            << endl;
*/

    }

    return 1;
}

