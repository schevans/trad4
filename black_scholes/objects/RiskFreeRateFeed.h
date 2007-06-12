#ifndef __RISK_FREE_RATE_FEED__
#define __RISK_FREE_RATE_FEED__

#include "RiskFreeRateFeedBase.h"



class RiskFreeRateFeed : public RiskFreeRateFeedBase {

public:

    RiskFreeRateFeed( int id ) { _id = id; }
    virtual ~RiskFreeRateFeed() {}

    virtual bool LoadFeedData();

};

#endif

