
#include <iostream>
#include <sys/types.h>
#include <sys/shm.h>
#include <sys/ipc.h>

using namespace std;

int create_shmem( void** ret_mem, size_t pub_size )
{

    int shmid;

    if ((shmid = shmget(IPC_PRIVATE, pub_size, IPC_CREAT | 0600)) == -1)
    {
        cout << "shmget error." << endl;
        exit(0);
    }

    if ((*ret_mem = shmat(shmid, NULL, 0)) == (char *) -1) {
        cout << "shmat error." << endl;
        exit(0);
    }

    return shmid;

}
 
