// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

#ifndef __OUTRIGHT_TRADE_AGG__
#define __OUTRIGHT_TRADE_AGG__

#include "OutrightTradeAggBase.h"

#include <map>

class OutrightTradeAgg : public OutrightTradeAggBase {

public:

    OutrightTradeAgg( int id ) { _id = id; }
    virtual ~OutrightTradeAgg() {}

    virtual bool Calculate();

private:

    std::map<int,double> _pvs;
    std::map<int,double> _pnls;

    double _acc_pv;
    double _acc_pnl;
};

#endif

