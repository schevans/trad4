
// Please see the comment at the top of jpm_cds/gen/objects/credit_curve_macros.c
//  to see what's in-scope.

#include <iostream>

#include "credit_curve_wrapper.c"

#include "isda_cds_model_c_v1.7/lib/include/isda/version.h"
#include "isda_cds_model_c_v1.7/lib/include/isda/macros.h"
#include "isda_cds_model_c_v1.7/lib/include/isda/cerror.h"
#include "isda_cds_model_c_v1.7/lib/include/isda/tcurve.h"
#include "isda_cds_model_c_v1.7/lib/include/isda/cdsone.h"
#include "isda_cds_model_c_v1.7/lib/include/isda/convert.h"
#include "isda_cds_model_c_v1.7/lib/include/isda/zerocurve.h"
#include "isda_cds_model_c_v1.7/lib/include/isda/cds.h"
#include "isda_cds_model_c_v1.7/lib/include/isda/cxzerocurve.h"
#include "isda_cds_model_c_v1.7/lib/include/isda/dateconv.h"
#include "isda_cds_model_c_v1.7/lib/include/isda/date_sup.h"
#include "isda_cds_model_c_v1.7/lib/include/isda/busday.h"
#include "isda_cds_model_c_v1.7/lib/include/isda/ldate.h"

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
        NULL,
        credit_curve_recoveryRate,
        credit_curve_payAccOnDefault,
        credit_curve_couponInterval,
        credit_curve_paymentDcc,
        credit_curve_stubType,
        (long)credit_curve_badDayConv,
        calendar ));

}

