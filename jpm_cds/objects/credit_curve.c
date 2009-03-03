
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

if (JpmcdsErrMsgEnableRecord(20, 128) != SUCCESS)
exit(0);

TDate *endDates;
double *couponRates;

    endDates = NEW_ARRAY(TDate, credit_curve_nbDate);
    couponRates = NEW_ARRAY( double, credit_curve_nbDate );

    int i2;
    for ( i2=0 ; i2 < credit_curve_nbDate ; i2++ )
    {
        endDates[i2] = credit_curve_today + ( i2 * 365 );


        couponRates[i2] = 0.05;
    }

    TCurve *tmp = 0;
       
    tmp = (TCurve*)(&s_ir_curve_pTCurve);
 
    cout << "s_ir_curve_baseDate: " << s_ir_curve_baseDate << endl;
    cout << "s_ir_curve_pTCurve->fNumItems: " << s_ir_curve_pTCurve.fNumItems << endl;

    char* calendar = "NONE";

    TDate *local_endDates;
    local_endDates = NEW_ARRAY(TDate, credit_curve_nbDate);

    TBoolean local_includes = FALSE;

    cout << "credit_curve_endDates[3]: " << credit_curve_endDates[3] << endl;

    cout << "credit_curve_startDate: " << credit_curve_startDate << endl;

    TDateInterval couponInterval;
    couponInterval.prd = 1;
    couponInterval.prd_typ = 'A';
    couponInterval.flag = 0;


    TCurve* creditcurve = JpmcdsCleanSpreadCurve(
        credit_curve_today,
        &s_ir_curve_pTCurve,
        credit_curve_startDate,
        credit_curve_stepinDate,
        credit_curve_cashSettleDate,
        credit_curve_nbDate,
        endDates,
        credit_curve_couponRates,
        &local_includes,
        credit_curve_recoveryRate,
        credit_curve_payAccOnDefault,
        &couponInterval,
        credit_curve_paymentDcc,
        credit_curve_stubType,
        credit_curve_badDayConv,
        calendar );

    TBoolean local_isPriceClean = FALSE;
    double local_feeLegPV = 0;
    TDate local_startDate = 148559;
    TDate local_endDate = 153400;
    double local_notional = 10000;
    double local_couponRate = 0.16;
    TBoolean local_protectStart = FALSE;

    int result = JpmcdsCdsFeeLegPV(
        credit_curve_today,
        credit_curve_today,
        credit_curve_today,
        local_startDate,
        local_endDate,
        credit_curve_payAccOnDefault,
        NULL,
        credit_curve_stubType,
        local_notional,
        local_couponRate,
        credit_curve_paymentDcc,
        credit_curve_badDayConv,
        calendar,
        &s_ir_curve_pTCurve,
        creditcurve,
        local_protectStart,
        local_isPriceClean,
        &local_feeLegPV
    );

    printf("result: %d\n", result );
    printf("local_feeLegPV: %f\n", local_feeLegPV );


    FREE(local_endDates);
    
    char  **lines = NULL;

    /* print error log contents */
    printf("\n");
    printf("Error log contains:\n");
    printf("------------------:\n");

    lines = JpmcdsErrGetMsgRecord();
    if (lines == NULL)
        printf("(no log contents)\n");
    else
    {
        int i;
        for(i = 0; lines[i] != NULL; i++)
        {
            if (strcmp(lines[i],"") != 0)
                printf("%s\n", lines[i]);
        }
    }


}

