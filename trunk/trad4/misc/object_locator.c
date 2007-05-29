
// Copyright Steve Evans 2007
// steve@topaz.myzen.co.uk



#include <sys/ipc.h>
#include <sys/shm.h>
//#include <unistd.h>
#include <iostream>
//#include <sstream>
#include <fstream>

#include "../objects/trad4.h"

using namespace std;

int main(int argc,char *argv[]) {

    if ( argc != 1 ) {
        cout << "usege object_locator" << endl;
        exit(0);
    }

    if ( !MAX_OBJECTS ) {
        cout << "MAX_OBJECTS not set." << endl;
        exit(0);
    }

    int shmid;

    if ((shmid = shmget(IPC_PRIVATE, sizeof(obj_loc), IPC_CREAT | 0600)) == -1)
    {
        perror("shmget: shmget failed"); exit(1);
    }

    void* shm;

    if ((shm = shmat(shmid, NULL, 0)) == (char *) -1) {
        perror("shmat");
        exit(1);
    }

    for ( int i = 0 ; i < MAX_OBJECTS ; i++ ) 
    {
        ((obj_loc*)shm)->shmid[i] = 0;
    }

    fstream obj_loc_file("/tmp/obj_loc.shmid", ios::out);

    obj_loc_file << shmid << endl; 

    obj_loc_file.close();

    sleep ( 20000000 );

    return 0;
}
