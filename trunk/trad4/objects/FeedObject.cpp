
// Copyright Steve Evans 2007
// steve@topaz.myzen.co.uk

#include <iostream>
//#include <sys/ipc.h>
#include <sys/shm.h>
//#include <unistd.h> 
#include <fstream>

#include "FeedObject.h"

using namespace std;

void FeedObject::Init( int id )
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
    sprintf(file, "%d.%d.t4o", _id, Type() );

    _data_file_name = strcat( data_dir, file );

    SetObjectStatus( STARTING );

    cout << "Loading static.." << endl;
    Load();
    cout << "Done loading static.." << endl;

    AttachToObjLoc();
   
cout << "Setting _obj_loc->shmid[" << _id << "] = " << _shmid << endl;
 
    _obj_loc->shmid[_id] = _shmid;

    LoadFeedData();
}

void FeedObject::Run() 
{
    cout << "FeedObject::Run()" << endl;

    SetObjectStatus( RUNNING );

    while (1) {
        sleep ( 10000 );
    }

}

bool FeedObject::Stop() 
{
    cout << "Stopping " << _name << endl;
    _obj_loc->shmid[_id] = 0;
    return true;
}
