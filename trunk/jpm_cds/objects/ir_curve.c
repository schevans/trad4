// Copyright (c) Steve Evans 2009
// schevans@users.sourceforge.net
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE
//
// This application is based on the ISDA CDS Standard Model (version 1.7),  
// developed and supported in collaboration with Markit Group Ltd.

// Please see the comment at the top of jpm_cds/gen/objects/ir_curve_macros.h
//  to see what's in-scope.

#include <iostream>

#include "ir_curve_wrapper.c"

#include "zerocurve.h"

using namespace std;

int calculate_ir_curve( obj_loc_t obj_loc, long id )
{
    char *local_holidays = (char*)"None";

    ir_curve_pTCurve = (JpmcdsBuildIRZeroCurve(
        ir_curve_baseDate,
        ir_curve_st_observables_types,
        ir_curve_st_observables_dates,
        ir_curve_st_observables_rates,
        NUM_RATES,
        ir_curve_mmDCC,
        ir_curve_fixedSwapFreq,
        ir_curve_floatSwapFreq,
        ir_curve_fixedSwapDCC,
        ir_curve_floatSwapDCC,
        ir_curve_badDayConv,
        local_holidays));

    return 1;
}


