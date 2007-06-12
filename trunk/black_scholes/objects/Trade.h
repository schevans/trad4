#ifndef __TRADE__
#define __TRADE__

#include "TradeBase.h"



class Trade : public TradeBase {

public:

    Trade( int id ) { _id = id; }
    virtual ~Trade() {}

    virtual bool Calculate();

};

#endif

