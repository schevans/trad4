
// Copyright Steve Evans 2007
// steve@topaz.myzen.co.uk

#include <iostream>
//#include <sys/ipc.h>
#include <sys/shm.h>
//#include <unistd.h> 
#include <fstream>
#include <sstream>

#include "FeedObject.h"

using namespace std;

void FeedObject::Run() 
{
    cout << "FeedObject::Run()" << endl;

    LoadFeedData();

    SetStatus( RUNNING );

    while (1) {
        sleep ( 10000 );
    }

}

bool FeedObject::Stop() 
{
    cout << "Stopping " << _name << endl;
    SetStatus( STOPPED );
    return true;
}
