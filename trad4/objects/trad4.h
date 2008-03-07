// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk


#ifndef __TRAD4_H__
#define __TRAD4_H__

#include <sys/types.h>

#define MAX_OBJECTS 20000

#define NUM_OBJECTS 600

#define OBJECT_NAME_LEN 32

enum log_level {
    NONE,
};

enum object_status {
    STOPPED,
    RUNNING,
    FAILED
};

typedef struct {
    // Header
    time_t last_published;
    object_status status;
    void* (*calculator_fpointer)(void*);
    bool (*need_refresh_fpointer)(int);
    int type;
    char name[OBJECT_NAME_LEN];
} object_header;

#define DBG cout << __FILE__ << ": " << __LINE__ << endl;

#endif
