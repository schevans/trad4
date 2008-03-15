
#include <iostream>
#include <math.h>

#include "currency_curves_wrapper.c"

using namespace std;

void* calculate_currency_curves( currency_curves* pub_currency_curves , interest_rate_feed* sub_interest_rate_feed )
{
   //cout << "calculate_currency_curves()" << endl; 

    int current_period_start;
    int current_period_end;

    double gradient;
    double y_intercept;

    // Interpolate the IR first..

    for ( int indx = 0; indx < INTEREST_RATE_LEN - 1 ; indx++)
    {
        current_period_start = sub_interest_rate_feed->asof[indx];
        current_period_end = sub_interest_rate_feed->asof[indx+1];

if ( indx == 8 )
    current_period_end = 20000;

        gradient = ((  sub_interest_rate_feed->rate[indx] -  sub_interest_rate_feed->rate[indx+1] ) / (  sub_interest_rate_feed->asof[indx] -  sub_interest_rate_feed->asof[indx+1] ) );
        y_intercept = sub_interest_rate_feed->rate[indx] - gradient * sub_interest_rate_feed->asof[indx];

        //cout << "\tCurrent period start (" << indx << "): " << current_period_start << ", end: " << current_period_end << ", gradinet: " << gradient << ", y_intercept: " << y_intercept << endl;

        for ( int i = current_period_start ; i <= current_period_end ; i++ )
        {
            //cout << "\tDate " << i << " index  " << i - DATE_RANGE_START << " rate: " <<(  i*gradient + y_intercept ) << endl;
            pub_currency_curves->interest_rate_interpol[i - DATE_RANGE_START] = (  i*gradient + y_intercept );
        }

    }
    
    // Then calc the discount rates..

    for ( int i = 0 ; i < DATE_RANGE_LEN ; i++ )
    {
        //cout << "Libor: " << pub_currency_curves->interest_rate_interpol[i] << ", Disco: " << exp( -pub_currency_curves->interest_rate_interpol[i] * (( i / YEAR_BASIS)/ YEAR_BASIS ) ) << " Year frac: " << ( i/ YEAR_BASIS ) << endl;

        pub_currency_curves->discount_rate[i] = exp( -pub_currency_curves->interest_rate_interpol[i] * (( i / YEAR_BASIS)/ YEAR_BASIS ) );

        pub_currency_curves->discount_rate_01[i] = exp( -(pub_currency_curves->interest_rate_interpol[i] -0.0001) * (( i / YEAR_BASIS)/ YEAR_BASIS ) );
    }

}

