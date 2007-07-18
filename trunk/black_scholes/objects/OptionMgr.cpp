// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE
// 
#include <sys/ipc.h>
#include <sys/shm.h>
#include <iostream>

#include "OptionMgr.h"

using namespace std;

bool OptionMgr::Calculate()
{
    cout << "OptionMgr::Calculate()" << endl;

    vector<Object*>::iterator iter;
    for( iter = _elements.begin() ; iter < _elements.end() ; iter++ )
    {
        (*iter)->Calculate();
        (*iter)->Notify();
    }

    Notify();
    return true;
}

