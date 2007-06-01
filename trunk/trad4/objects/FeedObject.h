
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

    void Run();
    void Init( int id );
    virtual bool Stop();

    virtual void SetObjectStatus( object_status status ) = 0;
    virtual bool LoadFeedData() = 0;

};

#endif
