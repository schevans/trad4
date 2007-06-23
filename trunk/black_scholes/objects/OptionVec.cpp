#include <sys/ipc.h>
#include <sys/shm.h>
#include <iostream>

#include "OptionVec.h"

using namespace std;

bool OptionVec::Calculate()
{
    cout << "OptionVec::Calculate()" << endl;

    vector<Object*>::iterator iter;
    for( iter = _elements.begin() ; iter < _elements.end() ; iter++ )
    {
        (*iter)->Calculate();
        (*iter)->Notify();
    }

    Notify();

    return true;
}

