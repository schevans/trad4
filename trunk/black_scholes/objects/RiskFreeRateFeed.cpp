#include <sys/ipc.h>
#include <sys/shm.h>
#include <iostream>

#include "RiskFreeRateFeed.h"

using namespace std;

bool RiskFreeRateFeed::LoadFeedData()
{
    cout << "RiskFreeRateFeed::LoadFeedData()" << endl;

    Load();

    Notify();
    return true;
}

