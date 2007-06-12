#include <sys/ipc.h>
#include <sys/shm.h>
#include <iostream>

#include "StockFeed.h"

using namespace std;

bool StockFeed::LoadFeedData()
{
    cout << "StockFeed::LoadFeedData()" << endl;

    Notify();
    return true;
}

