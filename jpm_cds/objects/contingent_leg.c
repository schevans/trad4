
// Please see the comment at the top of jpm_cds/gen/objects/contingent_leg_macros.c
//  to see what's in-scope.

#include <iostream>

#include "contingent_leg_wrapper.c"

#include "include/version.h"
#include "include/macros.h"
#include "include/cerror.h"
#include "include/tcurve.h"
#include "include/cdsone.h"
#include "include/convert.h"
#include "include/zerocurve.h"
#include "include/cds.h"
#include "include/cxzerocurve.h"
#include "include/dateconv.h"
#include "include/date_sup.h"
#include "include/busday.h"
#include "include/ldate.h"


using namespace std;

void calculate_contingent_leg( obj_loc_t obj_loc, int id )
{
    int result = JpmcdsCdsContingentLegPV(
        s_credit_curve_today,
        s_credit_curve_today,
        s_trade_startDate,
        s_trade_endDate,
        s_trade_notional,
        &s_ir_curve_pTCurve,
        &s_credit_curve_pTCurve,
        s_trade_recoveryRate,
        s_trade_protectStart,
        &contingent_leg_pv
    );

cout << "calculate_contingent_leg result: " << result << endl;
cout << "calculate_contingent_leg pv: " << contingent_leg_pv << endl;

}

