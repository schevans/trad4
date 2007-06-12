#include <sys/ipc.h>
#include <sys/shm.h>
#include <iostream>

#include <math.h>

#include "Trade.h"

using namespace std;

bool Trade::Calculate()
{
    cout << "Trade::Calculate()" << endl;

cout << _sub_risk_free_rate_feed->rate << "W" << GetTimeToMaturity() << endl;

    _ln_SoK = log( _sub_stock_feed->stock_price / GetStrikePrice() );
    _rT = _sub_risk_free_rate_feed->rate * GetTimeToMaturity();
    _v2T_2 = ( _sub_stock_feed->volatility2 * GetTimeToMaturity() ) / 2.0;
    _v_rtT = _sub_stock_feed->volatility * sqrt( GetTimeToMaturity() );
    _KerT = GetStrikePrice() * exp ( -_rT );

//cout << "\n_ln_SoK: " << _ln_SoK << "\n_rT: " << _rT << "\n_v2T_2: " << _v2T_2 << "\n_v_rtT: " << _v_rtT << "\n_KerT: " << _KerT << endl;

    _d1 = ( _ln_SoK + _rT + _v2T_2 ) / _v_rtT;
    _d2 = ( _ln_SoK + _rT - _v2T_2 ) / _v_rtT;

//cout << "_d1: " << _d1 << "\n_d2: " << _d2 << endl;

    if ( GetCallOrPut() == CALL )
    {

//cout << "_sub_stock_feed->stock_price: " << _sub_stock_feed->stock_price << endl;
//cout << "CalcCumNormDist( _d2 ): " << CalcCumNormDist( _d2 ) << endl;
//cout << "CalcCumNormDist( _d1 ): " << CalcCumNormDist( _d1 ) << endl;

        _price = _sub_stock_feed->stock_price * CalcCumNormDist( _d1 ) -  _KerT * CalcCumNormDist( _d2 );
    }
    else
    {
        _price = _KerT * CalcCumNormDist( -_d2 ) - _sub_stock_feed->stock_price * CalcCumNormDist( -_d1 );
    }

//cout << "Price: " << _price << endl;

    SetPrice( _price );

    Notify();
    return true;
}

double Trade::CalcCumNormDist( double x )
{
    return nc( x );
}

double Trade::ndf(double t)
{
return 0.398942280401433*exp(-t*t/2);
}

double Trade::nc(double x)
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
