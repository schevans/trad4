// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

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

