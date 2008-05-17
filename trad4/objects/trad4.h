// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk


#ifndef __TRAD4_H__
#define __TRAD4_H__

#include <sys/types.h>

#define MAX_OBJECTS 1400000
#define MAX_THREADS 4
#define MAX_TIERS 5
#define MAX_TYPES 15

#define OBJECT_NAME_LEN 32

#define DEBUG_ON 1

typedef void* obj_loc_t[MAX_OBJECTS+1];
typedef int tier_manager_t[MAX_TIERS+1][MAX_OBJECTS+1];

typedef void (*calculate_fpointer)(obj_loc_t obj_loc, int i);
typedef int (*need_refresh_fpointer)(obj_loc_t obj_loc, int id );
typedef void (*load_objects_fpointer)(obj_loc_t obj_loc, tier_manager_t tier_manager );

typedef struct {
    void* lib_handle;
    calculate_fpointer calculate;
    need_refresh_fpointer need_refresh;
    load_objects_fpointer load_objects;
    void* constructor_fpointer;
} object_type_struct_t;


#ifdef DEBUG_ON
#define DEBUG( debug ) if ( ((object_header*)obj_loc[id])->log_level == 1 ) std::cout << debug << std::endl;
#define DEBUG_FINE( debug ) if ( ((object_header*)obj_loc[id])->log_level > 1 ) std::cout << debug << std::endl;
#else
#define DEBUG( debug )
#define DEBUG_FINE( debug )
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
    RELOADED,
    NEW
};

typedef struct {
    // Header
    time_t last_published;
    int id;
    object_status status;
    void (*calculator_fpointer)(obj_loc_t,int);
    int (*need_refresh_fpointer)(obj_loc_t,int);
    int type;
    char name[OBJECT_NAME_LEN];
    int log_level; 
} object_header;

#define DBG cout << __FILE__ << ": " << __LINE__ << endl;

#endif
