#include <sys/ipc.h>
#include <sys/shm.h>
#include <iostream>

#include "Trade.h"

using namespace std;

bool Trade::Calculate()
{
    cout << "Trade::Calculate()" << endl;

    Notify();
    return true;
}

