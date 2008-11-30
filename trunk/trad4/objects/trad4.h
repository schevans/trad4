// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk


#ifndef __TRAD4_H__
#define __TRAD4_H__

#include <sys/types.h>

#define MAX_OBJECTS 1400000
#define MAX_THREADS 32
#define MAX_TIERS 5
#define MAX_TYPES 15

#define OBJECT_NAME_LEN 32

#define DEBUG_ON 1

typedef void* obj_loc_t[MAX_OBJECTS+1];
typedef int tier_manager_t[MAX_TIERS+1][MAX_OBJECTS+1];

typedef void (*calculate_fpointer)( obj_loc_t obj_loc, int id );
typedef int (*need_refresh_fpointer)( obj_loc_t obj_loc, int id );
typedef void (*load_objects_fpointer)( obj_loc_t obj_loc, int initial_load );
typedef int (*validate_fpointer)( obj_loc_t obj_loc, int initial_load );
typedef void (*printer_fpointer)( obj_loc_t obj_loc, tier_manager_t tier_manager );

void run_trad4();

typedef struct {
    void* lib_handle;
    calculate_fpointer calculate;
    need_refresh_fpointer need_refresh;
    load_objects_fpointer load_objects;
    void* constructor_fpointer; // Not used in beta.
    validate_fpointer validate;
} object_type_struct_t;


#ifdef DEBUG_ON
#define DEBUG( debug ) if ( ((object_header*)obj_loc[id])->log_level > 0 ) std::cout << debug << std::endl;
#define DEBUG_FINE( debug ) if ( ((object_header*)obj_loc[id])->log_level > 1 ) std::cout << debug << std::endl;
#define DEBUG_LOADS( debug ) if ( ((object_header*)obj_loc[id])->log_level > 2 ) std::cout << debug << std::endl;
#else
#define DEBUG( debug )
#define DEBUG_FINE( debug )
#define DEBUG_LOADS( debug )
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

// Hack to get the beta out (precomp expects only one string per type)...
#define long_long long long

typedef struct {
    // Header
    long long last_published;
    int id;
    object_status status;
    int type;
    int tier;
    char name[OBJECT_NAME_LEN];
    int log_level; 
} object_header;

#define DBG cout << __FILE__ << ": " << __LINE__ << endl;

#endif
