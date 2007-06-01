#include <sys/ipc.h>
#include <sys/shm.h>
#include <iostream>

#include "DiscountRate.h"

using namespace std;

bool DiscountRate::Calculate()
{
    cout << "DiscountRate::Calculate()" << endl;

    Notify();
    return true;
}

DiscountRate::DiscountRate( int id )
{
    cout << "DiscountRate::DiscountRate: "<< id << endl;

    _pub = (pub_discount_rate*)CreateShmem(sizeof(pub_discount_rate));

    Init( id );
}

