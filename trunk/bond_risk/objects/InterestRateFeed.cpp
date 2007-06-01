#include <sys/ipc.h>
#include <sys/shm.h>
#include <iostream>

#include "InterestRateFeed.h"

using namespace std;

bool InterestRateFeed::LoadFeedData()
{
    cout << "InterestRateFeed::LoadFeedData()" << endl;

    Notify();
    return true;
}

InterestRateFeed::InterestRateFeed( int id )
{
    cout << "InterestRateFeed::InterestRateFeed: "<< id << endl;

    _pub = (pub_interest_rate_feed*)CreateShmem(sizeof(pub_interest_rate_feed));

    Init( id );
}

