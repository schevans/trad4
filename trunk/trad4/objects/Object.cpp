
// Copyright Steve Evans 2007
// steve@topaz.myzen.co.uk

#include <iostream>
//#include <sys/ipc.h>
#include <sys/shm.h>
//#include <unistd.h> 
#include <fstream>

#include "Object.h"

using namespace std;

void Object::Init( int id )
{
    _id = id;

    _data_file_name ="/home/steve/src/trad_bond_risk/data/4.1.t4o";

    SetObjectStatus( STARTING );

    cout << "Loading static.." << endl;
    Load();
    cout << "Done loading static.." << endl;

    AttachToObjLoc();

    cout << "Attaching to subscriptions..." << endl;

    while ( ! AttachToSubscriptions() ) {
        cout << _name << " can't attach." << endl;
        sleep(_sleep_time);
        SetObjectStatus( BLOCKED );
    }

}

void Object::Run() {
    cout << "Object::Run()" << endl;

    sleep(30);
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

void* Object::AttachToSubscription( int sub_id )
{

    int sub_shmid = _obj_loc->shmid[sub_id];

    if ( sub_shmid )
    {
        void* shm;

        if ((shm = shmat(sub_shmid, NULL, 0)) == (char *) -1) {
            perror("shmat");
            exit(1);
        }

        return shm;
    }
    else
    {
        return 0;
    }
}

void* Object::AttachToObjLoc()
{
    char* obj_loc_file = getenv( "OBJ_LOC_FILE" );

    if ( obj_loc_file == NULL )
    {
        cout << "OBJ_LOC_FILE not set. Exiting" << endl;
        exit(1);
    }

    fstream in_file(obj_loc_file, ios::in);

    char shmid_char[20]; //XXX

    in_file >> shmid_char;

    cout << shmid_char << endl;

    int shmid = atoi(shmid_char);

    void* shm;

    if ((shm = shmat(shmid, NULL, 0)) == (char *) -1) {
        perror("shmat");
        exit(1);
    }

    _obj_loc = (obj_loc*)shm;

}


