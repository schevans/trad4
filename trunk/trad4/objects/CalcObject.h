
// Copyright Steve Evans 2007
// steve@topaz.myzen.co.uk

#ifndef __CALC_OBJECT_H__
#define __CALC_OBJECT_H__
#include <string>

#include "Object.h"
#include "trad4.h"


class CalcObject : public Object {

public:

    virtual ~CalcObject() {}

    void Run();
    void* AttachToSubscription( int sub_id );

    virtual bool Stop();
    virtual bool LoadFeedData();

    virtual bool AttachToSubscriptions() = 0;
    virtual bool Save() = 0;
    virtual bool Load() = 0;
    virtual bool NeedRefresh() = 0;
    virtual bool Calculate() = 0;
    virtual int Type() = 0;

};

#endif
