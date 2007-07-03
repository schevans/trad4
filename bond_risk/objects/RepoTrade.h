// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

#ifndef __REPO_TRADE__
#define __REPO_TRADE__

#include "RepoTradeBase.h"



class RepoTrade : public RepoTradeBase {

public:

    RepoTrade( int id ) { _id = id; }
    virtual ~RepoTrade() {}

    virtual bool Calculate();

};

#endif

