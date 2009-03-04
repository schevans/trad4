
// Please see the comment at the top of jpm_cds/gen/objects/standard_risk_macros.c
//  to see what's in-scope.

#include <iostream>

#include "standard_risk_wrapper.c"

using namespace std;

void calculate_standard_risk( obj_loc_t obj_loc, int id )
{
    standard_risk_pv = s_contingent_leg_pv - s_fee_leg_pv;

    cout << "standard_risk_pv: " << standard_risk_pv << endl;
}

