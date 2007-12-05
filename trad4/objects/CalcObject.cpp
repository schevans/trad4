
// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the LGPL. For details see $TRAD4_ROOT/LICENCE


#include <iostream>
//#include <sys/ipc.h>
#include <sys/shm.h>
//#include <unistd.h> 
#include <fstream>

#include "CalcObject.h"

using namespace std;

void CalcObject::Run() {
    cout << "CalcObject::Run()" << endl;

    cout << "Attaching to subscriptions..." << endl;

    while ( ! AttachToSubscriptions() ) {
        SetStatus( BLOCKED );
        cout << GetName() << " can't attach." << endl;
        sleep(GetSleepTime());
    }

    SetStatus( RUNNING );

    while ( 1 ) {

//cout << GetName() << ": Looping.." << endl;
    
        CheckSubscriptions();

        if ( NeedRefresh() )
        {
cout << GetName() << ": Need refresh.." << endl;
            if ( Calculate() )
            {
                Notify();
            }
        }

        sleep(GetSleepTime());

    }


}

void* CalcObject::AttachToSubscription( int sub_id )
{
    cout << "CalcObject::AttachToSubscription: " << sub_id << endl;

    int sub_shmid( _obj_loc->shmid[sub_id ] );

cout << "sub shmid: " << sub_shmid << endl;

    if ( sub_shmid )
    {
        void* shm;

        if ((shm = shmat(sub_shmid, NULL, SHM_RDONLY)) == (char *) -1) {
            perror("shmat");
            exit(1);
        }

        if ( ((object_header*)(shm))->status != RUNNING && ((object_header*)(shm))->status != MANAGED ) {

            cout << "Object " << sub_id << " not runing. ";

            return 0;
        }
        else {
            return shm;
        }

    }
    else
    {
        return 0;
    }
}

bool CalcObject::LoadFeedData()
{
    cout << "CalcObject::LoadFeedData()" << endl;
    return true;
}

bool CalcObject::Stop()
{
    cout << "Stopping " << GetName() << endl;
    SetStatus( STOPPED );
    Save();

    ((object_header*)(_pub))->pid = 0;

     shmdt( _pub );

    return true;
}

