// Copyright (c) Steve Evans 2009
// steve@topaz.myzen.co.uk
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE
//
// This application is based on the ISDA CDS Standard Model (version 1.7),  
// developed and supported in collaboration with Markit Group Ltd.

// Please see the comment at the top of jpm_cds/gen/objects/contingent_leg_macros.h
//  to see what's in-scope.

#include <iostream>

#include "contingent_leg_wrapper.c"

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

