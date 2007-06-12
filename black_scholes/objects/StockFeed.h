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

