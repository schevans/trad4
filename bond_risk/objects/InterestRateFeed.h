#ifndef __INTEREST_RATE_FEED__
#define __INTEREST_RATE_FEED__

#include "InterestRateFeedBase.h"



class InterestRateFeed : public InterestRateFeedBase {

public:

    InterestRateFeed( int id );
    virtual ~InterestRateFeed() {}

    virtual bool LoadFeedData();

};

#endif

