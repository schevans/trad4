
#include <iostream>
#include <math.h>

#include "bs_delta_wrapper.c"

double ndf(double t);
double nc(double x);


void* calculate_bs_delta( int id )
{
    std::cout << "stock_feed_S: " << stock_feed_S << std::endl;

    double vv = stock_feed_v * stock_feed_v;
    double vRtT = stock_feed_v * sqrt( option_feed_T );


    bs_delta_d1 =  ( log( stock_feed_S / option_feed_K ) + ( risk_free_rate_feed_r + ( vv / 2.0 ) ) * option_feed_T ) / vRtT;

    bs_delta_d2 = bs_delta_d1 - vRtT;

    bs_delta_Npd1 = ndf( bs_delta_d1 );

    bs_delta_Npd2 = ndf( bs_delta_d2 );

    if ( option_feed_call_or_put == CALL )
        bs_delta_delta = bs_delta_Npd1;
    else
        bs_delta_delta = bs_delta_Npd1 - 1.0;

std::cout << "delta: " << bs_delta_delta << std::endl;

}

double ndf(double t)
{
    return 0.398942280401433*exp(-t*t/2);
}

double nc(double x)
{
    double result;

    if (x<-7.)
        result = ndf(x)/sqrt(1.+x*x);
    else if (x>7.)
        result = 1. - nc(-x);
    else
    {
        result = 0.2316419;
        static double a[5] = {0.31938153,-0.356563782,1.781477937,-1.821255978,1.330274429};
        result=1./(1+result*fabs(x));
        result=1-ndf(x)*(result*(a[0]+result*(a[1]+result*(a[2]+result*(a[3]+result*a[4])))));

        if (x<=0.) 
            result=1.-result;
    }

    return result;
}

