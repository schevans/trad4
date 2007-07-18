// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE
// 
#ifndef __OPTION_MGR__
#define __OPTION_MGR__

#include "OptionMgrBase.h"



class OptionMgr : public OptionMgrBase {

public:

    OptionMgr( int id ) { _id = id; }
    virtual ~OptionMgr() {}

    virtual bool Calculate();

};

#endif

