
// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

#include <sys/ipc.h>
#include <sys/shm.h>
#include <iostream>

#include "RiskFreeRateFeed.h"

using namespace std;

bool RiskFreeRateFeed::LoadFeedData()
{
    cout << "RiskFreeRateFeed::LoadFeedData()" << endl;

    Load();

    return true;
}

