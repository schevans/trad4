/*
 * ISDA CDS Standard Model
 *
 * Copyright (C) 2009 International Swaps and Derivatives Association, Inc.
 * Developed and supported in collaboration with Markit
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the ISDA CDS Standard Model Public License.
 */

#include "version.h"
#include "macros.h"
#include "cerror.h"
#include "tcurve.h"
#include "cdsone.h"
#include "convert.h"
#include "zerocurve.h"
#include "cds.h"
#include "cxzerocurve.h"
#include "dateconv.h"
#include "date_sup.h"
#include "busday.h"
#include "ldate.h"


/*
***************************************************************************
** Build IR zero curve.
***************************************************************************
*/
TCurve* BuildExampleZeroCurve()
{
    static char  *routine = "BuildExampleZeroCurve";
    TCurve       *zc = NULL;
    char         *types = "MMMMMSSSSSSSSS";
    char         *expiries[14] = {"1M", "2M", "3M", "6M", "9M", "1Y", "2Y", "3Y", "4Y", "5Y", "6Y", "7Y", "8Y", "9Y"};
    TDate        *dates = NULL;
    double        rates[14] = {0.04, 0.04, 0.04, 0.04, 0.04, 0.04, 0.04, 0.04, 0.04, 0.04, 0.04, 0.04, 0.04, 0.04};
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

printf("mmDCC: %d\n", mmDCC );
printf("dcc: %d\n", dcc );
printf("ivl: %d\n", ivl );
printf("freq: %f\n", freq );

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
done:
    FREE(dates);
    return zc;
}


/*
***************************************************************************
** Calculate upfront charge.
***************************************************************************
*/
double CalcUpfrontCharge(TCurve* curve, double couponRate)
{
    static char  *routine = "CalcUpfrontCharge";
    TDate         today;
    TDate         valueDate;
    TDate         startDate;
    TDate         benchmarkStart;
    TDate         stepinDate;
    TDate         endDate;
    TBoolean      payAccOnDefault = TRUE;
    TDateInterval ivl;
    TStubMethod   stub;
    long          dcc;
    double        parSpread = 3600;
    double        recoveryRate = 0.4;
    TBoolean      isPriceClean = FALSE;
    double        notional = 1e7;
    double        result = -1.0;

    if (curve == NULL)
    {
        JpmcdsErrMsg("CalcUpfrontCharge: NULL IR zero curve passed\n");
        goto done;
    }

    today          = JpmcdsDate(2008, 2, 1);
    valueDate      = JpmcdsDate(2008, 2, 1);
    benchmarkStart = JpmcdsDate(2008, 2, 2);
    startDate      = JpmcdsDate(2008, 2, 8);
    endDate        = JpmcdsDate(2008, 2, 12);
    stepinDate     = JpmcdsDate(2008, 2, 9);

    if (JpmcdsStringToDayCountConv("Act/360", &dcc) != SUCCESS)
        goto done;
    
    if (JpmcdsStringToDateInterval("1S", routine, &ivl) != SUCCESS)
        goto done;

    if (JpmcdsStringToStubMethod("f/s", &stub) != SUCCESS)
        goto done;

    if (JpmcdsCdsoneUpfrontCharge(today,
                                  valueDate,
                                  benchmarkStart,
                                  stepinDate,
                                  startDate,
                                  endDate,
                                  couponRate / 10000.0,
                                  payAccOnDefault,
                                  &ivl,
                                  &stub,
                                  dcc,
                                  'F',
                                  "None",
                                  curve,
                                  parSpread / 10000.0,
                                  recoveryRate,
                                  isPriceClean,
                                  &result) != SUCCESS) goto done;
done:
    return result * notional;
}


/*
***************************************************************************
** Main function.
***************************************************************************
*/
int main(int argc, char** argv)
{

    int     status = 1;
    char    version[256];
    char  **lines = NULL;
    int     i;
    TCurve *zerocurve = NULL;

    if (JpmcdsVersionString(version) != SUCCESS)
        goto done;

    /* print library version */
    printf("starting...\n");
    printf("%s\n", version);
    
    /* enable logging */
    printf("enabling logging...\n");
    if (JpmcdsErrMsgEnableRecord(20, 128) != SUCCESS) /* ie. 20 lines, each of max length 128 */
        goto done;

    /* construct IR zero curve */
    printf("building zero curve...\n");
    zerocurve = BuildExampleZeroCurve();
    if (zerocurve == NULL)
        goto done;

    /* get discount factor */
    printf("\n");
    printf("Discount factor on 3rd Jan 08 = %f\n", JpmcdsZeroPrice(zerocurve, JpmcdsDate(2008,1,3)));
    printf("Discount factor on 3rd Jan 09 = %f\n", JpmcdsZeroPrice(zerocurve, JpmcdsDate(2009,1,3)*100000.0));
    printf("Discount factor on 3rd Jan 17 = %f\n", JpmcdsZeroPrice(zerocurve, JpmcdsDate(2017,1,3)));

    /* get upfront charge */
    printf("\n");
    printf("Upfront charge @ cpn = 0bps    =  %f\n", CalcUpfrontCharge(zerocurve, 0));
    printf("Upfront charge @ cpn = 3600bps =  %f\n", CalcUpfrontCharge(zerocurve, 3600));
    printf("Upfront charge @ cpn = 7200bps = %f\n", CalcUpfrontCharge(zerocurve, 7200));
    
    /* return 'no error' */
    status = 0;

    printf("\nCDS Stuff starts\n");

    TDate baseDate = JpmcdsDate(2008, 1, 3);
    long nbDate = 14;
    TDate *endDates;
    double *couponRates;

    endDates = NEW_ARRAY(TDate, nbDate);
    couponRates = NEW_ARRAY( double, nbDate );

    double recoveryRate = 0.4;
    TBoolean payAccOnDefault = FALSE;

    TDateInterval couponInterval;
    couponInterval.prd = 1;
    couponInterval.prd_typ = 'A';
    couponInterval.flag = 0;

    long paymentDCC = 4;

    TStubMethod stubType;
    stubType.stubAtEnd = FALSE;
    stubType.longStub = FALSE;

    long badDayConv = JPMCDS_BAD_DAY_NONE;
    char *calendar = "NONE";

    int i2;
    for ( i2=0 ; i2 < nbDate ; i2++ )
    {
        endDates[i2] = baseDate + ( i2 * 365 );

        couponRates[i2] = 0.05;
    }

    TBoolean includes = FALSE;

printf("baseDate: %d\n", baseDate );

    TCurve* creditcurve = JpmcdsCleanSpreadCurve(
        baseDate, 
        zerocurve,
        baseDate,
        baseDate,
        baseDate,
        nbDate,
        endDates,
        couponRates,
        &includes,
        recoveryRate,
        payAccOnDefault,
        &couponInterval,
        paymentDCC,
        &stubType,
        badDayConv,
        calendar );

    printf("Discount factor on 3rd Jan 08 = %f\n", JpmcdsZeroPrice(creditcurve, JpmcdsDate(2009,1,3)));

    TDate startDate = 148559;
    TDate endDate = 153400;
    double notional = 10000;
    double couponRate = 0.16;
    TBoolean protectStart = FALSE;

    TBoolean isPriceClean = FALSE; 
    double feeLegPV = 0;   

    TDate stepinDate = 150000;

    int result = JpmcdsCdsFeeLegPV(
        baseDate,
        baseDate,
        baseDate,
        startDate,
        endDate,
        payAccOnDefault,
        NULL,
        &stubType,
        notional,
        couponRate,
        paymentDCC,
        badDayConv,
        calendar,
        zerocurve,
        creditcurve,
        protectStart,
        isPriceClean,
        &feeLegPV
    );
         
    printf("feeLegPV: %f\n", feeLegPV );

    double contingentLegPV = 0;
   
    result = JpmcdsCdsContingentLegPV(
        baseDate,
        baseDate,
        startDate,
        endDate,
        notional,
        zerocurve,
        creditcurve,
        recoveryRate,
        protectStart,
        &contingentLegPV
    );

    printf("contingentLegPV: %f\n", contingentLegPV );

    printf("PV: %f\n", contingentLegPV - feeLegPV );

    FREE(endDates);
    FREE(couponRates);

    printf("CDS Stuff ends\n\n");

done:
    if (status != 0)
        printf("\n*** ERROR ***\n");

    /* print error log contents */
    printf("\n");
    printf("Error log contains:\n");
    printf("------------------:\n");

    lines = JpmcdsErrGetMsgRecord();
    if (lines == NULL)
        printf("(no log contents)\n");
    else
    {
        for(i = 0; lines[i] != NULL; i++)
        {
            if (strcmp(lines[i],"") != 0)
                printf("%s\n", lines[i]);
        }
    }

    FREE(zerocurve);
    return status;
}
