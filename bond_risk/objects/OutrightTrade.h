// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

#ifndef __OUTRIGHT_TRADE__
#define __OUTRIGHT_TRADE__

#include "OutrightTradeBase.h"



class OutrightTrade : public OutrightTradeBase {

public:

    OutrightTrade( int id ) { _id = id; }
    virtual ~OutrightTrade() {}

    virtual bool Calculate();

};

#endif

