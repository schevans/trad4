#ifndef __TRADE__
#define __TRADE__

#include "TradeBase.h"



class Trade : public TradeBase {

public:

    Trade( int id ) { _id = id; }
    virtual ~Trade() {}

    virtual bool Calculate();

private:

    double CalcCumNormDist( double x );
    double nc( double x );
    double ndf( double x );

    double _price;

    double _d1;
    double _d2;

    double _ln_SoK;
    double _rT;
    double _v2T_2;
    double _v_rtT;
    double _KerT;
};

#endif

