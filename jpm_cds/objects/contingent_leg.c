// Copyright (c) Steve Evans 2009
// schevans@users.sourceforge.net
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE
//
// This application is based on the ISDA CDS Standard Model (version 1.7),  
// developed and supported in collaboration with Markit Group Ltd.

// Please see the comment at the top of jpm_cds/gen/objects/contingent_leg_macros.h
//  to see what's in-scope.

#include <iostream>

#include "contingent_leg_wrapper.c"

#include "cds.h"

using namespace std;

int calculate_contingent_leg( obj_loc_t obj_loc, long id )
{
    int result = JpmcdsCdsContingentLegPV(
        s_trade_today,
        s_trade_valueDate,
        s_trade_startDate,
        s_trade_endDate,
        s_trade_notional,
        s_ir_curve_pTCurve,
        s_credit_curve_pTCurve,
        s_trade_recoveryRate,
        s_trade_protectStart,
        &contingent_leg_pv
    );

cout << "calculate_contingent_leg result: " << result << endl;

    return 1;
}

