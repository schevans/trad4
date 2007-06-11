
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

    _shmem_created = false;

    if ( _obj_loc->shmid[_id] ) 
    {
        cout << "Shmid found for this object" << endl;

        int shmid = _obj_loc->shmid[_id];

        void* shm;

        if ((shm = shmat(shmid, NULL, 0)) == (char *) -1) {
            perror("shmat");
            ExitOnError();
        }

        if ( ((object_header*)(shm))->status == RUNNING ) {

            cout << "Object already running" << endl;
            ExitOnError();
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
    ((object_header*)_pub)->pid = getpid(); 

    string data_dir( getenv( "DATA_DIR" ));

    if ( data_dir.empty() )
    {
        cout << "DATA_DIR not set. Exiting" << endl;
        ExitOnError();
    }

    ostringstream stream;
    stream << data_dir << _id << "." << Type() << ".t4o";

    _data_file_name = stream.str();

    cout << "Loading static.." << endl;
    Load();
    cout << "Done loading static.." << endl;



}

void* Object::CreateShmem( size_t pub_size )
{
    cout  <<"Object::CreateShmem( " << pub_size << " )" << endl;


    if ((_shmid = shmget(IPC_PRIVATE, pub_size, IPC_CREAT | 0600)) == -1)
    {
        perror("shmget: shmget failed"); ExitOnError();
    }

    void* shm;

    if ((shm = shmat(_shmid, NULL, 0)) == (char *) -1) {
        perror("shmat");
        ExitOnError();
    }

    _shmem_created = true;

    return shm;

}

bool Object::AttachToObjLoc()
{
    char* obj_loc_file = getenv( "OBJ_LOC_FILE" );

    if ( obj_loc_file == NULL )
    {
        cout << "OBJ_LOC_FILE not set. Exiting" << endl;
        ExitOnError();
    }

    fstream in_file(obj_loc_file, ios::in);

    if ( ! in_file ) 
    {
        cout << "obj_loc not running. Exiting." << endl;
        ExitOnError();
    }

    char shmid_char[20]; //XXX

    in_file >> shmid_char;

    cout << "Attaching to obj_loc shmid: " << shmid_char << endl;

    _obj_loc_shmid = atoi(shmid_char);

    void* shm;

    if ((shm = shmat(_obj_loc_shmid, NULL, 0)) == (char *) -1) {
        perror("shmat");
        ExitOnError();
    }

    _obj_loc = (obj_loc*)shm;

cout << "_obj_loc: " << _obj_loc << endl;

    return true;
}

bool Object::DetachFromObjLoc()
{
    if (shmdt( _obj_loc ) == -1) {
        perror("shmdt");
    }
    
    return true;
}

bool Object::Notify()
{    
    time_t temp;

    (void) time(&temp);

    *(int*)_pub = temp;

    return true;
}

void Object::ExitOnError()
{
    cout << "Object::ExitOnError()" << endl;

    SetStatus(FAILED);

    if ( _shmem_created )
    {
        if (shmctl(_shmid, IPC_RMID, 0) == -1) {
            perror("shmctl IPC_RMID: ");
        }
        _obj_loc->shmid[_id] = 0;
    }

    DetachFromObjLoc();
    
    exit(1);
}
