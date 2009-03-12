
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
    // Rate type descriptions e.g. swap, FRA I think. Will revisit this.
    char         *local_expiries[14] = {"1M", "2M", "3M", "6M", "9M", "1Y", "2Y", "3Y", "4Y", "5Y", "6Y", "7Y", "8Y", "9Y"};
    TDate        *local_dates = NULL;
    int           i, n;

    // No support for char* in trad4 internals, so I've mapped this to an int in the DB and
    //  hardcoding here for now.
    char *local_holidays = "None";

    // I think this is just for the Error log..
    static char  *local_routine = "BuildExampleZeroCurve";

    n = strlen((const char*)&ir_curve_types);

    local_dates = NEW_ARRAY(TDate, n);
    for (i = 0; i < n; i++)
    {
        TDateInterval tmp;

        if (JpmcdsStringToDateInterval(local_expiries[i], local_routine, &tmp) != SUCCESS)
        {
            JpmcdsErrMsg ("%s: invalid interval for element[%d].\n", local_routine, i);
            goto done;
        }
        
        if (JpmcdsDateFwdThenAdjust(ir_curve_baseDate, &tmp, JPMCDS_BAD_DAY_NONE, "None", local_dates+i) != SUCCESS)
        {
            JpmcdsErrMsg ("%s: invalid interval for element[%d].\n", local_routine, i);
            goto done;
        }
    }
 
    printf("calling JpmcdsBuildIRZeroCurve...\n");
    ir_curve_pTCurve = *(JpmcdsBuildIRZeroCurve(
            ir_curve_baseDate,
            (char*)&ir_curve_types,
            local_dates,
            ir_curve_rates,
            n,
            ir_curve_mmDCC,
            (long)ir_curve_freq,
            (long)ir_curve_freq,
            ir_curve_dcc,
            ir_curve_dcc,
            ir_curve_badDayConv,
            local_holidays));

    /* get discount factor */
    printf("\n");
    printf("Discount factor on 3rd Jan 08 = %f\n", JpmcdsZeroPrice(&ir_curve_pTCurve, JpmcdsDate(2008,1,3)));
    printf("Discount factor on 3rd Jan 09 = %f\n", JpmcdsZeroPrice(&ir_curve_pTCurve, JpmcdsDate(2009,1,3)));
    printf("Discount factor on 3rd Jan 17 = %f\n", JpmcdsZeroPrice(&ir_curve_pTCurve, JpmcdsDate(2017,1,3)));

done:
    FREE(local_dates);
}


