// Copyright (c) Steve Evans 2009
// steve@topaz.myzen.co.uk
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE
//
// This application is based on the ISDA CDS Standard Model (version 1.7),  
// developed and supported in collaboration with Markit Group Ltd.

// Please see the comment at the top of jpm_cds/gen/objects/ir_curve_macros.c
//  to see what's in-scope.

#include <iostream>

#include "ir_curve_wrapper.c"

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

void calculate_ir_curve( obj_loc_t obj_loc, int id )
{
    char *local_holidays = "None";

    ir_curve_pTCurve = *(JpmcdsBuildIRZeroCurve(
            ir_curve_baseDate,
            ir_curve_types,
            ir_curve_dates,
            ir_curve_rates,
            NUM_RATES,
            ir_curve_mmDCC,
            ir_curve_fixedSwapFreq,
            ir_curve_floatSwapFreq,
            ir_curve_fixedSwapDCC,
            ir_curve_floatSwapDCC,
            ir_curve_badDayConv,
            local_holidays));

}


