
#include <sys/shm.h>
#include <fstream>
#include <signal.h>
#include <iostream>

#include "trad4.h"

using namespace std;

int main(int argc,char *argv[]) {

    if ( argc != 2 ) {
        cout << "usege: halt_object <id>" << endl;
        exit(0);
    }

    int id=atoi(argv[1]);

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

    int object_shmid = master_obj_loc->shmid[id];

    if ( object_shmid == 0 )
    {
        cout << "No shmid found for object " << id << ". Exiting." << endl;
        exit(1);
    } 

    void* object_shm;

    if ((object_shm = shmat(object_shmid, NULL, 0)) == (char *) -1) {
        perror("shmat");
        exit(1);
    }

    int pid = ((object_header*)(object_shm))->pid;

    cout << "Sending SUGHUP to " << pid << endl;

    kill( pid, SIGHUP);

    return 0;
}
