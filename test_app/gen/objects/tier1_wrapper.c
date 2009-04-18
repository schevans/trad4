

#include <iostream>
#include <sstream>
#include <cstdlib>
#include <cstring>
#include <sstream>


#include "trad4.h"
#include "tier1.h"
#include "tier1_macros.h"

#include <sqlite3.h>

static int counter(0);

void calculate_tier1( obj_loc_t obj_loc, int id );
void load_tier1_double_array( obj_loc_t obj_loc, int i, sqlite3* db, int initial_load );

using namespace std;

extern "C" void* constructor()
{
    return new tier1;
}

extern "C" void calculate( obj_loc_t obj_loc, int id )
{
    DEBUG( "calculate_tier1( " << ((tier1*)obj_loc[id])->name << " )" );

    DEBUG_FINE( "static:" );
    DEBUG_FINE( "\ttier1_int1: " << tier1_int1 );
    DEBUG_FINE( "\ttier1_int2: " << tier1_int2 );
    DEBUG_FINE( "\ttier1_struct_scalar: " << tier1_struct_scalar );

    DEBUG_FINE( "sub:" );

    calculate_tier1( obj_loc, id );

    DEBUG_FINE( "pub:");
    DEBUG( "\ttier1_int_out: " << tier1_int_out );

}

extern "C" int need_refresh( obj_loc_t obj_loc, int id )
{
    DEBUG_LOADS( "tier1_need_refresh( " << id << ")" );

    DEBUG_LOADS( "	tier1 timestamp: " <<  *(long long*)obj_loc[id] );
    DEBUG_LOADS( "	tier1 state: " << ((object_header*)obj_loc[id])->status );

    int retval = ( (((object_header*)obj_loc[id])->status == RELOADED ) || (((object_header*)obj_loc[id])->status == STOPPED ) && (  0 ));

    DEBUG_LOADS( "	returning: " << retval )

    return retval;

}

extern "C" int validate( obj_loc_t obj_loc, int id )
{
    int retval=0;

    return retval;

}


static int load_objects_callback(void *obj_loc_v, int argc, char **row, char **azColName)
{
    // Have to cast to unsigned char** here as C++ doesn't like
    //  void* arithmetic for some strange reason... 
    unsigned char** obj_loc = (unsigned char**)obj_loc_v;

    int id = atoi(row[0]);

    bool is_new(false);

    if ( !obj_loc[id] ) 
    {
        obj_loc[id] = (unsigned char*)(new tier1);
        is_new = true;
    }

    ((tier1*)obj_loc[id])->id = id;
    ((tier1*)obj_loc[id])->log_level = atoi(row[3]);
    ((tier1*)obj_loc[id])->last_published = 0;

    ((tier1*)obj_loc[id])->status = RELOADED;

    //((tier1*)obj_loc[id])->calculator_fpointer = &calculate_tier1_wrapper;
    //((tier1*)obj_loc[id])->need_refresh_fpointer = &tier1_need_refresh;
    ((tier1*)obj_loc[id])->type = 1;
    ((tier1*)obj_loc[id])->implements = 1;
    memcpy( ((tier1*)obj_loc[id])->name, row[1], 32 );
    ((tier1*)obj_loc[id])->tier = atoi(row[2]);
    
    ((tier1*)obj_loc[id])->int1 = atoi(row[4]);
//    ((tier1*)obj_loc[id])->struct_scalar = 0(row[5]);
    ((tier1*)obj_loc[id])->int2 = atoi(row[6]);
    ((tier1*)obj_loc[id])->int_out = 0;

    if ( is_new )
    {
        //std::cout << "New tier1 created." << std::endl;
    }

    return 0;
} 

extern "C" void load_objects( obj_loc_t obj_loc, int initial_load )
{
    std::cout << "load_all_tier1()" << std::endl;

    char *zErrMsg = 0;
    sqlite3* db;
    sqlite3_open(getenv("APP_DB"), &db);

    std::ostringstream dbstream;
    dbstream << "select object.id, object.name, object.tier, object.log_level, tier1.int1, tier1.int2, tier1.struct_scalar, tier1.double_array from object, object_types, tier1 where object.id = tier1.id and object_types.type_id = object.type_id and object.type_id = 1";

    if ( initial_load != 1 )
        dbstream << " and o.need_reload=1";

    if( sqlite3_exec(db, dbstream.str().c_str(), load_objects_callback, obj_loc, &zErrMsg) != SQLITE_OK ){
        fprintf(stderr, "SQL error: %s. File %s, line %d.\n", zErrMsg, __FILE__, __LINE__);
        sqlite3_free(zErrMsg);
    }

}

static int load_tier1_double_array_callback(void *obj_loc_v, int argc, char **row, char **azColName)
{
    unsigned char** obj_loc = (unsigned char**)obj_loc_v;
    int id = atoi(row[0]);

    if ( counter > 10 )
    {
        cerr << "Error in load_tier1_double_array: The number of rows in tier1_double_array.table is greater than 10. Truncating data in tier1_double_array structure to  elements. Suggest you fix the data or create a new type with larger arrays and migrate your objects across." << endl;
    }
    else
    {
        (tier1_double_array(counter)) = std::atof(row[1]);

        counter++;

    }

    return 0;
}

void load_tier1_double_array( obj_loc_t obj_loc, int id, sqlite3* db, int initial_load )
{
    cout << "	load_tier1_double_array()" << endl;

    counter = 0;
    char *zErrMsg = 0;

    std::ostringstream dbstream;
    dbstream << "select id, double_array from tier1_double_array where id = " << id;

    if( sqlite3_exec(db, dbstream.str().c_str(), load_tier1_double_array_callback, obj_loc, &zErrMsg) != SQLITE_OK ){
        fprintf(stderr, "SQL error: %s. File %s, line %d.\n", zErrMsg, __FILE__, __LINE__);
        sqlite3_free(zErrMsg);
    }

}

