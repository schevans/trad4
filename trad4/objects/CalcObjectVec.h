
// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the LGPL. For details see $TRAD4_ROOT/LICENCE


#ifndef __CALC_OBJECT_VEC_H__
#define __CALC_OBJECT_VEC_H__

#include <string>
#include <vector>

#include "CalcObject.h"
#include "trad4.h"


class CalcObjectVec : public CalcObject {

public:

    virtual ~CalcObjectVec() {}

    virtual void Run();
    virtual bool Stop();

    virtual bool AttachToSubscriptions() = 0;
    virtual bool CheckSubscriptions() = 0;
    virtual bool Save() = 0;
    virtual bool Load() = 0;
    virtual bool NeedRefresh() = 0;
    virtual bool Calculate() = 0;
    virtual int Type() = 0;

protected:

    std::vector<int> _element_ids;
    std::vector<Object*> _elements;
     

};

#endif
