// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk


#ifndef __TRAD4_H__
#define __TRAD4_H__

#include <sys/types.h>

#define MAX_OBJECTS 20000

#define MC //

#define NUM_OBJECTS 1400000

#define NUM_THREADS 4

#define NUM_TIERS 5

#define OBJECT_NAME_LEN 32

#define DEBUG_ON 1

#ifdef DEBUG_ON
#define DEBUG( debug ) if ( ((object_header*)obj_loc[id])->log_level > 0 ) std::cout << debug << std::endl;
#else
#define DEBUG( debug )
#endif

enum logging_level {
    NONE,
    SOME,
    LOADS
};

enum object_status {
    STOPPED,
    RUNNING,
    FAILED,
    RELOADED
};

typedef struct {
    // Header
    time_t last_published;
    int id;
    object_status status;
    void* (*calculator_fpointer)(void*);
    bool (*need_refresh_fpointer)(int);
    int type;
    char name[OBJECT_NAME_LEN];
    int log_level; 
} object_header;

#define DBG cout << __FILE__ << ": " << __LINE__ << endl;

#endif
