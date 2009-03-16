
// Please see the comment at the top of jpm_cds/gen/objects/fee_leg_macros.c
//  to see what's in-scope.

#include <iostream>

#include "fee_leg_wrapper.c"

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

void calculate_fee_leg( obj_loc_t obj_loc, int id )
{
    char* calendar = "NONE";

    int result = JpmcdsCdsFeeLegPV(
            s_trade_today,
            s_trade_valueDate,
            s_trade_stepinDate,
            s_trade_startDate,
            s_trade_endDate,
            s_trade_payAccOnDefault,
            NULL,
            s_trade_stubType,
            s_trade_notional,
            s_trade_couponRate,
            s_trade_paymentDcc,
            s_trade_badDayConv,
            calendar,
            &s_ir_curve_pTCurve,
            &s_credit_curve_pTCurve,
            s_trade_protectStart,
            s_trade_isPriceClean,
            &fee_leg_pv
        );

cout << "calculate_fee_leg result: " << result << endl;

}

