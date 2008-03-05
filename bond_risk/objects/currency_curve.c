
#include <iostream>
#include <math.h>

#include "trad4.h"
#include "currency_curve.h"
#include "interest_rate_feed.h"

extern void* obj_loc[NUM_OBJECTS+1];
extern void set_timestamp( int id );

using namespace std;

void* calculate_currency_curve( void* id )
{
   cout << "calculate_currency_curve( " << (int)id << " )" << endl; 

DBG
    currency_curve* _pub = (currency_curve*)obj_loc[(int)id];
    interest_rate_feed* sub = (interest_rate_feed*)(obj_loc[(_pub->interest_rate_feed)]);

DBG
    int current_period_start;
    int current_period_end;

DBG
    double gradient;
    double y_intercept;

    // Interpolate the IR first..

cout << "TING2: " << sub->asof[9]  << endl;



    for ( int indx = 0; indx < INTEREST_RATE_LEN - 1 ; indx++)
    {
        current_period_start = sub->asof[indx];
        current_period_end = sub->asof[indx+1];

if ( indx == 8 )
    current_period_end = 20000;

        gradient = ((  sub->rate[indx] -  sub->rate[indx+1] ) / (  sub->asof[indx] -  sub->asof[indx+1] ) );
        y_intercept = sub->rate[indx] - gradient * sub->asof[indx];

        //cout << "\tCurrent period start (" << indx << "): " << current_period_start << ", end: " << current_period_end << ", gradinet: " << gradient << ", y_intercept: " << y_intercept << endl;

        for ( int i = current_period_start ; i <= current_period_end ; i++ )
        {
            //cout << "\tDate " << i << " index  " << i - DATE_RANGE_START << " rate: " <<(  i*gradient + y_intercept ) << endl;
            _pub->interest_rate_interpol[i - DATE_RANGE_START] = (  i*gradient + y_intercept );
        }

    }
    
    // Then calc the discount rates..

    for ( int i = 0 ; i < DATE_RANGE_LEN ; i++ )
    {
        //cout << "Libor: " << _pub->interest_rate_interpol[i] << ", Disco: " << exp( -_pub->interest_rate_interpol[i] * (( i / YEAR_BASIS)/ YEAR_BASIS ) ) << " Year frac: " << ( i/ YEAR_BASIS ) << endl;

        _pub->discount_rate[i] = exp( -_pub->interest_rate_interpol[i] * (( i / YEAR_BASIS)/ YEAR_BASIS ) );

        _pub->discount_rate_01[i] = exp( -(_pub->interest_rate_interpol[i] -0.0001) * (( i / YEAR_BASIS)/ YEAR_BASIS ) );
    }

    set_timestamp((int)id);

}

bool currency_curve_need_refresh( int id )
{
return ( (((object_header*)obj_loc[id])->status == STOPPED ) && ( *(int*)obj_loc[id] < *(int*)obj_loc[((currency_curve*)obj_loc[id])->interest_rate_feed] ) ||  0 );
}
