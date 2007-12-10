
// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the LGPL. For details see $TRAD4_ROOT/LICENCE

#include <sys/shm.h>
#include <fstream>

#include <iostream>

#include "trad4.h"

using namespace std;

int main(int argc,char *argv[]) {

    if ( argc != 1 ) {
        cout << "usege: reset_trad4" << endl;
        exit(0);
    }

    char* obj_loc_file_name = getenv( "OBJ_LOC_FILE" );

    if ( obj_loc_file_name == NULL )
    {
        cout << "OBJ_LOC_FILE not set. Exiting" << endl;
        exit(1);
    }

    fstream obj_loc_file(obj_loc_file_name, ios::in);

    if ( ! obj_loc_file.is_open() )
    {
        cout << "obj_loc not running. Exiting." << endl;
        exit (1);
    }

    char shmid_char[OBJ_LOC_SHMID_LEN];

    obj_loc_file >> shmid_char;

    cout << "Attaching to obj_loc shmid: " << shmid_char << endl;

    int shmid = atoi(shmid_char);

    obj_loc_file.close();

    void* shm;

    if ((shm = shmat(shmid, NULL, 0)) == (char *) -1) {
        perror("shmat");
        exit(1);
    }

    obj_loc* master_obj_loc = (obj_loc*)shm;

    struct shmid_ds shmid_ds;

    for ( int i = 0 ; i < MAX_OBJECTS ; i++ )
    {
        shmctl( master_obj_loc->shmid[i], IPC_RMID, &shmid_ds );
    }

    shmctl( shmid, IPC_RMID, &shmid_ds );

    cout << "All shmem scheduled for deletion." << endl;

    return 0;
}
