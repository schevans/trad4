// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

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

    for ( int i = 0 ; i < DATE_RANGE_LEN ; i++ )
    {
        //cout << "Libor: " << _sub_interest_rate_feed->rate_interpol[i] << ", Disco: " << exp( -_sub_interest_rate_feed->rate_interpol[i] * (( i / YEAR_BASIS)/ YEAR_BASIS ) ) << " Year frac: " << ( i/ YEAR_BASIS ) << endl;

        ((discount_rate*)_pub)->rate[i] = exp( -_sub_interest_rate_feed->rate_interpol[i] * (( i / YEAR_BASIS)/ YEAR_BASIS ) );

        ((discount_rate*)_pub)->rate_01[i] = exp( -(_sub_interest_rate_feed->rate_interpol[i] +0.0001) * (( i / YEAR_BASIS)/ YEAR_BASIS ) );
    }

    Notify();
    return true;
}


