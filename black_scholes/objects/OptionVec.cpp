#include <sys/ipc.h>
#include <sys/shm.h>
#include <iostream>

#include "OptionVec.h"

using namespace std;

bool OptionVec::Calculate()
{
    cout << "OptionVec::Calculate()" << endl;
DBG
DBG
    vector<Object*>::iterator iter;
    for( iter = _elements.begin() ; iter < _elements.end() ; iter++ )
    {
        (*iter)->Calculate();
DBG
        (*iter)->Notify();
DBG
    }
DBG
    Notify();
DBG
    return true;
}

