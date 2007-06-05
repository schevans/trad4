
// Copyright Steve Evans 2007
// steve@topaz.myzen.co.uk

#include <iostream>
//#include <sys/ipc.h>
#include <sys/shm.h>
//#include <unistd.h> 
#include <fstream>

#include "CalcObject.h"

using namespace std;

void CalcObject::Init( int id )
{
    _id = id;

    char* data_dir;
    data_dir = getenv( "DATA_DIR" );

    if ( data_dir == NULL )
    {
        cout << "DATA_DIR not set. Exiting" << endl;
        exit(1);
    }

    char file[20];
    sprintf(file, "%d.%d.t4o", _id, GetType() );

    _data_file_name = strcat( data_dir, file );

    SetStatus( STARTING );

    cout << "Loading static.." << endl;
    Load();
    cout << "Done loading static.." << endl;

    AttachToObjLoc();

cout << "_obj_loc2: " << _obj_loc << endl;



    _obj_loc->shmid[_id] = _shmid;

}

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
    _obj_loc->shmid[_id] = 0;
    Save();

    return true;
}

