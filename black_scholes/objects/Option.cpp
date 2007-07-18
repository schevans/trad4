#include <sys/ipc.h>
#include <sys/shm.h>
#include <iostream>

#include <math.h>

#include "Option.h"

using namespace std;

bool Option::Calculate()
{
    cout << "Option::Calculate()" << endl;

    // We'll always need _RtT.
    _RtT = sqrt( GetTimeToMaturity() );

    // Here's the question: What's updated - the stock or the risk free rate?
    // Note - it might be both which is why both are explicidly tested for.
    if ( _sub_stock_feed->last_published > *(int*)_pub )
    {
        // It's the stock feed, so we'll need this lot.
        // Note that if we had volatility as a seperate object, we'd get the benifit here.

        // Stock price dependancies:
        _ln_SK = log( _sub_stock_feed->stock_price / GetStrikePrice() );

        // Vol dependancies:
        _v2T_2 = ( _sub_stock_feed->volatility2 * GetTimeToMaturity() ) / 2.0;
        _vRtT = _sub_stock_feed->volatility * _RtT;

        // Both
        _Sv = _sub_stock_feed->stock_price * _sub_stock_feed->volatility;
    }

    if ( _sub_risk_free_rate_feed->last_published > *(int*)_pub )
    {
        // Risk free rate's changed. We'll need these recalculated.
        _rT = _sub_risk_free_rate_feed->rate * GetTimeToMaturity();
        _KerT = GetStrikePrice() * exp ( -_rT );
        _rKerT = _sub_risk_free_rate_feed->rate * _KerT;
    }

    cout << "\n_ln_SK: " << _ln_SK << "\n_rT: " << _rT << "\n_v2T_2: " << _v2T_2 << "\n_vRtT: " << _vRtT << "\n_KerT: " << _KerT << endl;

    // We'll always need both d1 & d2 recalculated - they depend on both feeds.
    _d1 = ( _ln_SK + _rT + _v2T_2 ) / _vRtT;
    _d2 = ( _ln_SK + _rT - _v2T_2 ) / _vRtT;

    //cout << "_d1: " << _d1 << "\n_d2: " << _d2 << endl;

    _N_pd1 = CalcCumNormDist( +_d1 );
    
    // Gamma & Vega are the same for calls & puts.
    SetGamma( _N_pd1 / ( _Sv * _RtT )); 
    SetVega( _sub_stock_feed->stock_price * _N_pd1 * _RtT );

    if ( GetCallOrPut() == CALL )
    {
        // We only need these three if this opton's a call.
        _N_pd2 = CalcCumNormDist( +_d2 );
        _SN_pd1 = _sub_stock_feed->stock_price * _N_pd1;
        _KerTN_pd2 = _KerT * _N_pd2;

        SetPrice( _SN_pd1 - _KerTN_pd2 );
        SetDelta( _N_pd1 );
        SetTheta(  (-( _Sv * _N_pd1 ) / 2 * _RtT ) - ( _rKerT * _N_pd2 ));
        SetRho( _KerT * GetTimeToMaturity() * _N_pd2 ); 
    }
    else
    {
        // We only need these three if this opton's a put.
        _N_md2 = CalcCumNormDist( -_d2 );
        _SN_md1 = _sub_stock_feed->stock_price * CalcCumNormDist( -_d1 );
        _KerTN_md2 = _KerT * _N_md2;

        SetPrice( _KerTN_md2 - _SN_md1 );
        SetDelta( _N_pd1 - 1 );
        SetTheta( (-( _Sv * _N_pd1 ) / 2 * _RtT ) + ( _rKerT * _N_md2 ));
        SetRho( -_KerT * GetTimeToMaturity() * _N_pd2 ); 
    }

    // Boilerplate - likely to be moved into OptionBase.
    Notify();
    return true;
}

double Option::CalcCumNormDist( double x )
{
    return nc( x );
}

double Option::ndf(double t)
{
return 0.398942280401433*exp(-t*t/2);
}

double Option::nc(double x)
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
if (x<=0.) result=1.-result;
}
return result;
}

