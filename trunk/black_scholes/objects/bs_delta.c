
// Please see the comment at the top of black_scholes/gen/objects/bs_delta_macros.c
//  to see what's in-scope.

#include <iostream>
#include <math.h>

#include "bs_delta_wrapper.c"

using namespace std;

double CumeNormDist(const double x);

int calculate_bs_delta( obj_loc_t obj_loc, int id )
{
    double d1 =  ( sstock_trade_ln_SK + srate_trade_rT  + sstock_trade_vvT_2 ) / sstock_trade_vRtT;

    double d2 = d1 - sstock_trade_vRtT;

    bs_delta_N_pd1 = CumeNormDist( d1 );

    bs_delta_N_pd2 = CumeNormDist( d2 );

    bs_delta_N_md1 = CumeNormDist( - d1 );

    bs_delta_N_md2 = CumeNormDist( - d2 );

    if ( soption_call_or_put == CALL )
    {
        bs_delta_delta = bs_delta_N_pd1;
    }
    else
    {
        bs_delta_delta = bs_delta_N_pd1 - 1.0;
    }

    return 1;
}

double CumeNormDist(const double x)
{
  const double b1 =  0.319381530;
  const double b2 = -0.356563782;
  const double b3 =  1.781477937;
  const double b4 = -1.821255978;
  const double b5 =  1.330274429;
  const double p  =  0.2316419;
  const double c  =  0.39894228;

  if(x >= 0.0) {
      double t = 1.0 / ( 1.0 + p * x );
      return (1.0 - c * exp( -x * x / 2.0 ) * t *
      ( t *( t * ( t * ( t * b5 + b4 ) + b3 ) + b2 ) + b1 ));
  }
  else {
      double t = 1.0 / ( 1.0 - p * x );
      return ( c * exp( -x * x / 2.0 ) * t *
      ( t *( t * ( t * ( t * b5 + b4 ) + b3 ) + b2 ) + b1 ));
    }
}

