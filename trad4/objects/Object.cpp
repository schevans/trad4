
// Copyright Steve Evans 2007
// steve@topaz.myzen.co.uk

#include <unistd.h>
#include <sys/types.h>
#include <signal.h>


#include <iostream>
//#include <sys/ipc.h>
#include <sys/shm.h>
//#include <unistd.h> 
#include <fstream>
#include <sstream>

#include "Object.h"

using namespace std;

void Object::Init() 
{
    cout << "Object::Init()" << endl;

    AttachToObjLoc();

    if ( _obj_loc->shmid[_id] ) 
    {
        cout << "Shmid found for this object" << endl;

        int shmid = _obj_loc->shmid[_id];

        void* shm;

        if ((shm = shmat(shmid, NULL, 0)) == (char *) -1) {
            perror("shmat");
            exit(1);
        }

        if ( ((object_header*)(shm))->status == RUNNING ) {

            cout << "Object already running" << endl;
            exit(0);
        }
        else {
            cout << "Object has status " << ((object_header*)(shm))->status << endl;

            _pub = shm;
        }

    }
    else
    {
cout << "Creating shmem" << endl;
        _pub = CreateShmem(SizeOfStruct());
        _obj_loc->shmid[_id] = _shmid;
    }

    SetStatus( STARTING );

    ((object_header*)_pub)->type = Type(); 
cout << "TYPE2: " << Type() << endl;
DBG
    string data_dir( getenv( "DATA_DIR" ));

    if ( data_dir.empty() )
    {
        cout << "DATA_DIR not set. Exiting" << endl;
        exit(1);
    }

    ostringstream stream;
    stream << data_dir << _id << "." << Type() << ".t4o";

cout << "Type: " << Type() << endl;

    _data_file_name = stream.str();
cout << "_data_file_name:" << _data_file_name << endl;
DBG

DBG
    cout << "Loading static.." << endl;
    Load();
    cout << "Done loading static.." << endl;
DBG


}

void* Object::CreateShmem( size_t pub_size )
{
    cout  <<"Object::CreateShmem( " << pub_size << " )" << endl;


    if ((_shmid = shmget(IPC_PRIVATE, pub_size, IPC_CREAT | 0600)) == -1)
    {
        perror("shmget: shmget failed"); exit(1);
    }

    void* shm;

    if ((shm = shmat(_shmid, NULL, 0)) == (char *) -1) {
        perror("shmat");
        exit(1);
    }

    return shm;

}

bool Object::AttachToObjLoc()
{
    char* obj_loc_file = getenv( "OBJ_LOC_FILE" );

    if ( obj_loc_file == NULL )
    {
        cout << "OBJ_LOC_FILE not set. Exiting" << endl;
        exit(1);
    }

    fstream in_file(obj_loc_file, ios::in);

    if ( ! in_file ) 
    {
        cout << "obj_loc not running. Exiting." << endl;
        exit (1);
    }

    char shmid_char[20]; //XXX

    in_file >> shmid_char;

    cout << "Attaching to obj_loc shmid: " << shmid_char << endl;

    int shmid = atoi(shmid_char);

    void* shm;

    if ((shm = shmat(shmid, NULL, 0)) == (char *) -1) {
        perror("shmat");
        exit(1);
    }

    _obj_loc = (obj_loc*)shm;

cout << "_obj_loc: " << _obj_loc << endl;

    return true;
}

bool Object::Notify()
{    
    time_t temp;

    (void) time(&temp);

    *(int*)_pub = temp;

    return true;
}

