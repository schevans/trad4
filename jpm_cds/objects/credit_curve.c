
// Please see the comment at the top of jpm_cds/gen/objects/credit_curve_macros.c
//  to see what's in-scope.

#include <iostream>

#include "credit_curve_wrapper.c"

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

void calculate_credit_curve( obj_loc_t obj_loc, int id )
{
    char* calendar = "NONE";

    credit_curve_pTCurve = *(JpmcdsCleanSpreadCurve(
        credit_curve_today,
        &s_ir_curve_pTCurve,
        credit_curve_startDate,
        credit_curve_stepinDate,
        credit_curve_cashSettleDate,
        credit_curve_nbDate,
        credit_curve_endDates,
        credit_curve_couponRates,
        credit_curve_includes,
        credit_curve_recoveryRate,
        credit_curve_payAccOnDefault,
        credit_curve_couponInterval,
        credit_curve_paymentDcc,
        credit_curve_stubType,
        credit_curve_badDayConv,
        calendar ));

}

