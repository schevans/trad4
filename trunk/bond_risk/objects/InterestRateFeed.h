#ifndef __INTEREST_RATE_FEED__
#define __INTEREST_RATE_FEED__

#include "InterestRateFeedBase.h"



class InterestRateFeed : public InterestRateFeedBase {

public:

    InterestRateFeed( int id ) { _id = id; }
    virtual ~InterestRateFeed() {}

    virtual bool LoadFeedData();

private:

    std::string _feed_file;

};

#endif

