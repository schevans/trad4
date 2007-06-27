
// Copyright Steve Evans 2007
// steve@topaz.myzen.co.uk

#ifndef __CALC_OBJECT_AGG_H__
#define __CALC_OBJECT_AGG_H__

#include <string>
#include <vector>
#include <map>

#include "CalcObject.h"
#include "trad4.h"


class CalcObjectAgg : public CalcObject {

public:

    virtual ~CalcObjectAgg() {}

    virtual void Run();

    virtual bool AttachToSubscriptions() = 0;
    virtual bool CheckSubscriptions() = 0;
    virtual bool Save() = 0;
    virtual bool Load() = 0;
    virtual bool NeedRefresh() = 0;
    virtual bool Calculate() = 0;
    virtual int Type() = 0;

protected:

    std::vector<int> _element_ids;
    std::map<int,void*> _elements_map;
     

};

#endif
