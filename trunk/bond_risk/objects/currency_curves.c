// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk
//

#include <iostream>
#include <math.h>

#include "currency_curves_wrapper.c"

using namespace std;

void calculate_currency_curves( obj_loc_t obj_loc, int id )
{
    int current_period_start;
    int current_period_end;

    double gradient;
    double y_intercept;

    // Interpolate the IR first..
    for ( int indx = 0; indx < INTEREST_RATE_LEN - 1 ; indx++)
    {
        current_period_start = currency_curves_ir_rates_asof(indx);
        current_period_end = currency_curves_ir_rates_asof(indx+1);

        gradient = ((  currency_curves_ir_rates_value(indx) -  currency_curves_ir_rates_value(indx+1) ) / (  currency_curves_ir_rates_asof(indx) -  currency_curves_ir_rates_asof(indx+1) ) );
        y_intercept = currency_curves_ir_rates_value(indx) - gradient * currency_curves_ir_rates_asof(indx);

/*
        cout << "current_period_start: " << current_period_start 
            << ", current_period_end: " << current_period_end 
            << ", currency_curves_ir_rates_value(indx): " << currency_curves_ir_rates_value(indx)
            << ", currency_curves_ir_rates_value(indx+1): " << currency_curves_ir_rates_value(indx+1)
            << ", gradient: " << gradient 
            << ", y_intercept: " << y_intercept << endl;
*/
        for ( int i = current_period_start ; i < current_period_end ; i++ )
        {
            //cout << "\tDate " << i << " index  " << i - DATE_RANGE_START << " rate: " <<(  i*gradient + y_intercept ) << endl;
            currency_curves_interest_rate_interpol[i - DATE_RANGE_START] = (  i*gradient + y_intercept );
        }

    }
    
    // Then calc the discount rates..

    for ( int i = 0 ; i <= DATE_RANGE_LEN ; i++ )
    {
        currency_curves_discount_rate[i] = exp( -currency_curves_interest_rate_interpol[i] * (( i / YEAR_BASIS)/ YEAR_BASIS ) );

        currency_curves_discount_rate_p01[i] = exp( -(currency_curves_interest_rate_interpol[i] +0.0001) * (( i / YEAR_BASIS)/ YEAR_BASIS ) );

        currency_curves_discount_rate_m01[i] = exp( -(currency_curves_interest_rate_interpol[i] -0.0001) * (( i / YEAR_BASIS)/ YEAR_BASIS ) );

/*
        cout << "currency_curves_discount_rate[ " << i << "]: " << currency_curves_discount_rate[i]
            << ", currency_curves_discount_rate_p01[ " << i << "]: " << currency_curves_discount_rate_p01[i]
            << ", currency_curves_discount_rate_m01[ " << i << "]: " << currency_curves_discount_rate_m01[i]
            << endl;
*/
    }

}

