
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

void FeedObject::Init( int id )
{
    _id = id;

    string data_dir( getenv( "DATA_DIR" ) );
//    data_dir = getenv( "DATA_DIR" );

    if ( data_dir.empty() )
    {
        cout << "DATA_DIR not set. Exiting" << endl;
        exit(1);
    }

cout << "DDD: " << data_dir << endl;

    ostringstream stream;
    stream << data_dir << _id << "." << GetType() << ".t4o";

    _data_file_name = stream.str();

cout << "_data_file_name: " << _data_file_name << endl;

    SetStatus( STARTING );

    cout << "Loading static.." << endl;
    Load();
    cout << "Done loading static.." << endl;

    AttachToObjLoc();
   
cout << "Setting _obj_loc->shmid[" << _id << "] = " << _shmid << endl;
 
    _obj_loc->shmid[_id] = _shmid;

}

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
