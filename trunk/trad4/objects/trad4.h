// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk


#ifndef __TRAD4_H__
#define __TRAD4_H__

#include <fstream>
#include <sys/types.h>
#include "math.h"

#define MAX_OBJECTS 1400000
#define MAX_THREADS 4096
#define MAX_TIERS 10
#define MAX_TYPES 32


#define OBJECT_NAME_LEN 32

typedef void* obj_loc_t[MAX_OBJECTS+1];
typedef int tier_manager_t[MAX_TIERS+1][MAX_OBJECTS+1];

typedef void (*calculate_fpointer)( obj_loc_t obj_loc, int id );
typedef int (*need_refresh_fpointer)( obj_loc_t obj_loc, int id );
typedef void (*load_objects_fpointer)( obj_loc_t obj_loc, int initial_load );
typedef int (*validate_fpointer)( obj_loc_t obj_loc, int initial_load );
typedef void (*print_concrete_graph_fpointer)( obj_loc_t obj_loc, int id, std::ofstream& outfile );
typedef size_t (*get_object_size_fpointer)();

void run_trad4( int print_graph );

typedef struct {
    void* lib_handle;
    calculate_fpointer calculate;
    need_refresh_fpointer need_refresh;
    load_objects_fpointer load_objects;
    validate_fpointer validate;
    print_concrete_graph_fpointer print_concrete_graph;
    get_object_size_fpointer get_object_size;
} object_type_struct_t;

#define DEBUG_ON

#ifdef DEBUG_ON
#define DEBUG( debug ) if ( ((object_header*)obj_loc[id])->log_level > 0 ) std::cout << debug << std::endl;
#define DEBUG_FINE( debug ) if ( ((object_header*)obj_loc[id])->log_level > 1 ) std::cout << debug << std::endl;
#define DEBUG_LOADS( debug ) if ( ((object_header*)obj_loc[id])->log_level > 2 ) std::cout << debug << std::endl;
#else
#define DEBUG( debug )
#define DEBUG_FINE( debug )
#define DEBUG_LOADS( debug )
#endif

#define T4_TEST( val1, val2 ) if ( fabs(val1 - val2 ) > 0.01 ) std::cout << "T4_TEST failed for object id " << id  << ": " << val1 << " vs " << val2 << ", file " << __FILE__ << ", line " << __LINE__ << std::endl; else std::cout << "T4_TEST passed" << std::endl;

enum logging_level {
    NONE,
    SOME,
    LOADS
};

enum e_status {
    OK,
    STALE,
    FAILED
};

// Hack to get the beta out (precomp expects only one string per type)...
#define long_long long long

typedef struct {
    // Header
    long long last_published;
    int id;
    e_status status;
    int type;
    int tier;
    char name[OBJECT_NAME_LEN];
    int log_level; 
    int implements;
    int init;
} object_header;

#define object_last_published(index) ((object_header*)obj_loc[index])->last_published
#define object_status(index) ((object_header*)obj_loc[index])->status
#define object_type(index) ((object_header*)obj_loc[index])->type
#define object_tier(index) ((object_header*)obj_loc[index])->tier
#define object_name(index) ((object_header*)obj_loc[index])->name
#define object_log_level(index) ((object_header*)obj_loc[index])->log_level
#define object_implements(index) ((object_header*)obj_loc[index])->implements
#define object_init(index) ((object_header*)obj_loc[index])->init

// Server stuff. I really should extend the namespace use..
namespace t4 {

    enum request_type_enum {
        GET_HEADER,
        GET_BODY
    };

    typedef struct {
        request_type_enum request_type;
        int id;
    } request;

}

#define DBG cout << __FILE__ << ": " << __LINE__ << endl;

#endif
