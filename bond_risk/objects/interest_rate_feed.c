// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk
//

#include <iostream>
#include <vector>

#include "trad4.h"
#include "common.h"
#include "interest_rate_feed.h"

using namespace std;

extern void set_timestamp( int );

extern void* obj_loc[NUM_OBJECTS+1];

void* calculate_interest_rate_feed( void* id )
{
    cout << "InterestRateFeed::LoadFeedData()" << endl;


    // Hack to get this working. Otherwise lifted from trad_bond_risk.
    void* _pub = obj_loc[(int)id];

    int current_period_start;
    int current_period_end;

    double gradient;
    double y_intercept;

    for ( int indx = 0; indx < INTEREST_RATE_LEN - 1 ; indx++)
    {
        current_period_start = ((interest_rate_feed*)_pub)->asof[indx];
        current_period_end = ((interest_rate_feed*)_pub)->asof[indx+1];

        gradient = (( ((interest_rate_feed*)_pub)->rate[indx] - ((interest_rate_feed*)_pub)->rate[indx+1] ) / ( ((interest_rate_feed*)_pub)->asof[indx] - ((interest_rate_feed*)_pub)->asof[indx+1] ) );
        y_intercept = ((interest_rate_feed*)_pub)->rate[indx] - gradient * ((interest_rate_feed*)_pub)->asof[indx];

        for ( int i = current_period_start ; i <= current_period_end ; i++ )
        {
            //cout << "\tDate " << i << " index  " << i - DATE_RANGE_START << " rate: " <<(  i*gradient + y_intercept ) << endl;
            ((interest_rate_feed*)_pub)->rate_interpol[i - DATE_RANGE_START] = (  i*gradient + y_intercept );

        }

    }

    set_timestamp((int)id);
}

