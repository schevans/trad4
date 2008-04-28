
#include <iostream>
#include <math.h>

#include "bs_delta_wrapper.c"

double ndf(double t);
double nc(double x);


void calculate_bs_delta( obj_loc_t obj_loc, int id )
{
    DEBUG( "calculate_bs_delta( " << id << ")" )

cout << "rate_trade_rT: " << rate_trade_rT << endl;
cout << "stock_trade_ln_SK: " << stock_trade_ln_SK << endl;
cout << "stock_trade_vRtT: " << stock_trade_vRtT << endl;
cout << "stock_trade_vvT_2: " << stock_trade_vvT_2 << endl;

    bs_delta_d1 =  ( stock_trade_ln_SK + rate_trade_rT  + stock_trade_vvT_2 ) / stock_trade_vRtT;

cout << "d1: " << bs_delta_d1 << endl;

    bs_delta_d2 = bs_delta_d1 - stock_trade_vRtT;

    bs_delta_N_pd1 = ndf( bs_delta_d1 );

    bs_delta_N_pd2 = ndf( bs_delta_d2 );

    bs_delta_N_md1 = ndf( - bs_delta_d1 );

    bs_delta_N_md2 = ndf( - bs_delta_d2 );

    if ( option_feed_call_or_put == CALL )
    {
cout << "Call" << endl;
        bs_delta_delta = bs_delta_N_pd1;
    }
    else
    {
cout << "Put" << endl;
        bs_delta_delta = bs_delta_N_pd1 - 1.0;
    }

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

