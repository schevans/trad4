// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

#ifndef __STOCK_FEED__
#define __STOCK_FEED__

#include "StockFeedBase.h"



class StockFeed : public StockFeedBase {

public:

    StockFeed( int id ) { _id = id; }
    virtual ~StockFeed() {}

    virtual bool LoadFeedData();

};

#endif

