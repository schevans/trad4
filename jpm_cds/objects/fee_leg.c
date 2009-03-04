
// Please see the comment at the top of jpm_cds/gen/objects/fee_leg_macros.c
//  to see what's in-scope.

#include <iostream>

#include "fee_leg_wrapper.c"

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

void calculate_fee_leg( obj_loc_t obj_loc, int id )
{
    char* calendar = "NONE";

int result = JpmcdsCdsFeeLegPV(
        s_credit_curve_today,
        s_credit_curve_today,
        s_credit_curve_today,
        s_trade_startDate,
        s_trade_endDate,
        s_credit_curve_payAccOnDefault,
        NULL,
        s_credit_curve_stubType,
        s_trade_notional,
        s_trade_couponRate,
        s_credit_curve_paymentDcc,
        s_credit_curve_badDayConv,
        calendar,
        &s_ir_curve_pTCurve,
        &s_credit_curve_pTCurve,
        s_trade_protectStart,
        s_trade_isPriceClean,
        &fee_leg_pv
    );

cout << "calculate_fee_leg result: " << result << endl;
cout << "calculate_fee_leg pv: " << fee_leg_pv << endl;

}

