// Copyright (c) Steve Evans 2009
// steve@topaz.myzen.co.uk
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE
//
// This application is based on the ISDA CDS Standard Model (version 1.7),  
// developed and supported in collaboration with Markit Group Ltd.

// Please see the comment at the top of jpm_cds/gen/objects/standard_risk_macros.h
//  to see what's in-scope.

#include <iostream>
#include <math.h>

#include "standard_risk_wrapper.c"

using namespace std;

void calculate_standard_risk( obj_loc_t obj_loc, int id )
{
    standard_risk_pv = s_contingent_leg_pv - s_fee_leg_pv;

    cout << "standard_risk_pv: " << standard_risk_pv << endl;

    T4_TEST( standard_risk_pv, -8323.85 );
}

