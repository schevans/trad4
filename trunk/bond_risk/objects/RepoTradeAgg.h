// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

#ifndef __REPO_TRADE_AGG__
#define __REPO_TRADE_AGG__

#include "RepoTradeAggBase.h"



class RepoTradeAgg : public RepoTradeAggBase {

public:

    RepoTradeAgg( int id ) { _id = id; }
    virtual ~RepoTradeAgg() {}

    virtual bool Calculate();

private:

    std::map<int,double> _mtm_pnls; 
    std::map<int,double> _margins; 

    double _acc_margin;
    double _acc_mtm_pnl;
};

#endif

