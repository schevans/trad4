
// Copyright Steve Evans 2007
// steve@topaz.myzen.co.uk

#ifndef __TRAD4_H__
#define __TRAD4_H__

#include <sys/types.h>

#define MAX_OBJECTS 10000

#define MAX_OB_FILE_LEN 100
#define MAX_OB_FILE_NAME 20

enum log_level {
    NONE,
};

enum object_status {
    UNKNOWN,
    STOPPED,
    STARTING,
    RUNNING,
    BLOCKED,
    DISABLED
};

typedef struct {
    int shmid[MAX_OBJECTS];
} obj_loc;

typedef struct {
    time_t last_published;
    object_status status;
    int pid;
    int type;
    char* name;
    int sleep_time;
} object_header;


#define DBG cout << __FILE__ << ": " << __LINE__ << endl;

#endif
