#include <sys/ipc.h>
#include <sys/shm.h>
#include <iostream>

#include "Bond.h"

using namespace std;

bool Bond::Calculate()
{
    cout << "Bond::Calculate()" << endl;

    Notify();
    return true;
}

Bond::Bond( int id )
{
    cout << "Bond::Bond: "<< id << endl;

    _pub = (pub_bond*)CreateShmem(sizeof(pub_bond));

    Init( id );
}

