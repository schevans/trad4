
// Copyright Steve Evans 2007
// steve@topaz.myzen.co.uk

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
        cout << _name << " can't attach." << endl;
        sleep(GetSleepTime());
    }

    SetStatus( RUNNING );

    while ( 1 ) {

cout << _name << ": Looping.." << endl;

        if ( NeedRefresh() )
        {
cout << _name << ": Need refresh.." << endl;
            Calculate();
        }

        sleep(GetSleepTime());

    }


}

void* CalcObject::AttachToSubscription( int sub_id )
{
cout << "CalcObject::AttachToSubscription" << endl;
cout << _obj_loc << endl;
    int sub_shmid = _obj_loc->shmid[sub_id];

cout << "sub shmid: " << sub_shmid << endl;

    if ( sub_shmid )
    {
        void* shm;

        if ((shm = shmat(sub_shmid, NULL, 0)) == (char *) -1) {
            perror("shmat");
            exit(1);
        }

        if ( ((object_header*)(shm))->status != RUNNING ) {

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
    cout << "Stopping " << _name << endl;
    SetStatus( STOPPED );
    Save();

    return true;
}

