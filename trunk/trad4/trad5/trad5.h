// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk


#ifndef __TRAD5_H__
#define __TRAD5_H__

#include <sys/types.h>

#define MAX_OBJECTS 20000

#define MAX_OB_FILE_LEN 100
#define MAX_OB_FILE_NAME 20
#define MAX_OBJECT_TYPES_FILE_LEN 120

#define NUM_OBJECTS 3

//void* obj_loc[NUM_OBJECTS+1];


#define OBJ_LOC_SHMID_LEN 32

#define OBJECT_NAME_LEN 32

#define MONITOR_SLEEP_TIME 10

enum log_level {
    NONE,
};

enum object_status {
    UNKNOWN,
    STOPPED,
    STARTING,
    RUNNING,
    BLOCKED,
    FAILED,
    STALE,
    MANAGED
};

// Now declared globaly in trad5.c
//typedef struct {
//    int shmid[MAX_OBJECTS];
//} obj_loc;

typedef struct {
    // Header
    time_t last_published;
    object_status status;
    void* (*calculator_fpointer)(void*);
    bool (*need_refresh_fpointer)(int);
    int type;
    char name[OBJECT_NAME_LEN];
    int sleep_time;
} object_header;

#define DBG cout << __FILE__ << ": " << __LINE__ << endl;

#endif
