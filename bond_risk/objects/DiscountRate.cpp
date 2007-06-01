#include <sys/ipc.h>
#include <sys/shm.h>
#include <iostream>
#include <math.h>
#include <vector>

#include "DiscountRate.h"

using namespace std;

bool DiscountRate::Calculate()
{
    cout << "DiscountRate::Calculate()" << endl;

    int current_period_start;
    int current_period_end;

    float gradient;
    float y_intercept;

    unsigned int indx;

    vector<float> discount_rate;

    float normalised_interest_rate;
    float year_fraction;
    float discount_factor;

    for (indx = 0; indx < INTEREST_RATE_LEN ; indx++)
    {
        normalised_interest_rate = _sub_interest_rate_feed->rate[indx] / 100;
        year_fraction = ( _sub_interest_rate_feed->asof[indx] - 10000 ) / YEAR_BASIS;

        discount_factor = exp( -normalised_interest_rate * year_fraction );

        discount_rate.push_back( discount_factor );
    }

    for (indx = 0; indx < INTEREST_RATE_LEN - 1 ; indx++)
    {
        current_period_start = _sub_interest_rate_feed->asof[indx];
        current_period_end = _sub_interest_rate_feed->asof[indx+1];

        cout << "Grad calc[" << indx << "]: ( " << discount_rate[indx] << " - " << discount_rate[indx+1] << ") / (" << _sub_interest_rate_feed->asof[indx] << " - " << _sub_interest_rate_feed->asof[indx+1] << " )" <<  endl;

        gradient = (( discount_rate[indx] - discount_rate[indx+1] ) / ( _sub_interest_rate_feed->asof[indx] - _sub_interest_rate_feed->asof[indx+1] ) );
        y_intercept = discount_rate[indx] - gradient * _sub_interest_rate_feed->asof[indx];

        cout << current_period_start << " to " << current_period_end << ", start_rate= "<< discount_rate[indx] << ", end_rate= << " << discount_rate[indx+1] << " gradient: " << gradient << " y-inter:" << y_intercept << endl;

        for ( int i = current_period_start ; i <= current_period_end ; i++ )
        {
            cout << "\tDate " << i << " index  " << i - DATE_RANGE_START << " rate: " <<(  i*gradient + y_intercept ) << endl;
            ((pub_discount_rate*)_pub)->rate[i - DATE_RANGE_START] = (  i*gradient + y_intercept );

        }

    }

    Notify();
    return true;
}

DiscountRate::DiscountRate( int id )
{
    cout << "DiscountRate::DiscountRate: "<< id << endl;

    _pub = (pub_discount_rate*)CreateShmem(sizeof(pub_discount_rate));

    Init( id );
}

