// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

#include <sys/ipc.h>
#include <sys/shm.h>
#include <iostream>

#include "RepoTradeAgg.h"
#include "repo_trade.h"

using namespace std;

bool RepoTradeAgg::Calculate()
{
    cout << "RepoTradeAgg::Calculate()" << endl;

    vector<int>::iterator iter;
    for( iter = _element_ids.begin() ; iter < _element_ids.end() ; iter++ )
    {
        _mtm_pnls[*iter] = ((repo_trade*)(_elements_map[*iter]))->mtm_pnl;
        _acc_mtm_pnl = _acc_mtm_pnl + ((repo_trade*)(_elements_map[*iter]))->mtm_pnl;

        _margins[*iter] = ((repo_trade*)(_elements_map[*iter]))->margin;
        _acc_margin = _acc_margin + ((repo_trade*)(_elements_map[*iter]))->margin;
    }

    SetMtmPnl( _acc_mtm_pnl );
    SetMargin( _acc_margin );

    return true;
}

