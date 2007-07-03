// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

#ifndef __FX_RATE_FEED__
#define __FX_RATE_FEED__

#include "FxRateFeedBase.h"



class FxRateFeed : public FxRateFeedBase {

public:

    FxRateFeed( int id ) { _id = id; }
    virtual ~FxRateFeed() {}

    virtual bool LoadFeedData();

};

#endif

