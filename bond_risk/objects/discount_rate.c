// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk
//

#include <iostream>
#include <math.h>

#include "trad4.h"
#include "discount_rate.h"
#include "interest_rate_feed.h"

extern void* obj_loc[NUM_OBJECTS+1];
extern void set_timestamp( int id );

using namespace std;

void* calculate_discount_rate( void* id )
{
    // Hack to get this working. Otherwise lifted from trad_bond_risk.
    void* _pub = obj_loc[(int)id];
    interest_rate_feed* _sub_interest_rate_feed = (interest_rate_feed*)obj_loc[((discount_rate*)_pub)->interest_rate_feed];

    cout << "DiscountRate::Calculate()" << endl;

    for ( int i = 0 ; i < DATE_RANGE_LEN ; i++ )
    {
        //cout << "Libor: " << _sub_interest_rate_feed->rate_interpol[i] << ", Disco: " << exp( -_sub_interest_rate_feed->rate_interpol[i] * (( i / YEAR_BASIS)/ YEAR_BASIS ) ) << " Year frac: " << ( i/ YEAR_BASIS ) << endl;

        ((discount_rate*)_pub)->rate[i] = exp( -_sub_interest_rate_feed->rate_interpol[i] * (( i / YEAR_BASIS)/ YEAR_BASIS ) );

        ((discount_rate*)_pub)->rate_01[i] = exp( -(_sub_interest_rate_feed->rate_interpol[i] -0.0001) * (( i / YEAR_BASIS)/ YEAR_BASIS ) );
    }

    set_timestamp((int)id);
}


bool discount_rate_need_refresh( int id )
{
    return ( (((object_header*)obj_loc[id])->status == STOPPED ) && ( *(int*)obj_loc[id] < *(int*)obj_loc[((discount_rate*)obj_loc[id])->interest_rate_feed] ) ||  0 );
}
