
// Copyright Steve Evans 2007
// steve@topaz.myzen.co.uk

#ifndef __FEED_OBJECT_H__
#define __FEED_OBJECT_H__
#include <string>

#include "Object.h"
#include "trad4.h"

class FeedObject : public Object {

public:

    virtual ~FeedObject() {}

    virtual void Run();
    virtual bool Stop();

    virtual bool LoadFeedData() = 0;

    virtual bool Save() { return true; }
    virtual bool Calculate() { return true; }
    virtual bool AttachToSubscriptions() { return true; }
};

#endif
