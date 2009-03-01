
// Please see the comment at the top of jpm_cds/gen/objects/ir_curve_macros.c
//  to see what's in-scope.

#include <iostream>

#include "ir_curve_wrapper.c"

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

void calculate_ir_curve( obj_loc_t obj_loc, int id )
{
    static char  *routine = "BuildExampleZeroCurve";
    TCurve       *zc = NULL;
    char         *types = "MMMMMSSSSSSSSS";
    char         *expiries[14] = {"1M", "2M", "3M", "6M", "9M", "1Y", "2Y", "3Y", "4Y", "5Y", "6Y", "7Y", "8Y", "9Y"};
    TDate        *dates = NULL;
//    double        rates[14] = {1e-9, 1e-9, 1e-9, 1e-9, 1e-9, 1e-9, 1e-9, 1e-9, 1e-9, 1e-9, 1e-9, 1e-9, 1e-9, 1e-9};
    double        rates[14] = {1.4, 1.4, 1.4, 1.4, 1.4, 1.4, 1.4, 1.4, 1.4, 1.4, 1.4, 1.4, 1.4, 1.4};
    TDate         baseDate;
    long          mmDCC;
    TDateInterval ivl;
    long          dcc;
    double        freq;
    char          badDayConv = 'M';
    char         *holidays = "None";
    int           i, n;

    baseDate = JpmcdsDate(2008, 1, 3);

    if (JpmcdsStringToDayCountConv("Act/360", &mmDCC) != SUCCESS)
        goto done;
    
    if (JpmcdsStringToDayCountConv("30/360", &dcc) != SUCCESS)
        goto done;

    if (JpmcdsStringToDateInterval("6M", routine, &ivl) != SUCCESS)
        goto done;

    if (JpmcdsDateIntervalToFreq(&ivl, &freq) != SUCCESS)
        goto done;

    n = strlen(types);

    dates = NEW_ARRAY(TDate, n);
    for (i = 0; i < n; i++)
    {
        TDateInterval tmp;

        if (JpmcdsStringToDateInterval(expiries[i], routine, &tmp) != SUCCESS)
        {
            JpmcdsErrMsg ("%s: invalid interval for element[%d].\n", routine, i);
            goto done;
        }
        
        if (JpmcdsDateFwdThenAdjust(baseDate, &tmp, JPMCDS_BAD_DAY_NONE, "None", dates+i) != SUCCESS)
        {
            JpmcdsErrMsg ("%s: invalid interval for element[%d].\n", routine, i);
            goto done;
        }
    }
 
    printf("calling JpmcdsBuildIRZeroCurve...\n");
    zc = JpmcdsBuildIRZeroCurve(
            baseDate,
            types,
            dates,
            rates,
            n,
            mmDCC,
            (long) freq,
            (long) freq,
            dcc,
            dcc,
            badDayConv,
            holidays);

    /* get discount factor */
    printf("\n");
    printf("Discount factor on 3rd Jan 08 = %f\n", JpmcdsZeroPrice(zc, JpmcdsDate(2008,1,3)));
    printf("Discount factor on 3rd Jan 09 = %f\n", JpmcdsZeroPrice(zc, JpmcdsDate(2009,1,3)));
    printf("Discount factor on 3rd Jan 17 = %f\n", JpmcdsZeroPrice(zc, JpmcdsDate(2017,1,3)));

done:
    FREE(dates);
}

