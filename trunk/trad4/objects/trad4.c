// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk
//

#include <iostream>
#include <pthread.h>
#include <sys/time.h>
#include <signal.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <sstream>
#include <iomanip>
#include <sqlite3.h>

#include "trad4.h"

using namespace std;

obj_loc_t obj_loc;
tier_manager_t tier_manager;
int thread_contoller[MAX_THREADS+1];
object_type_struct_t* object_type_struct[MAX_TYPES+1];
sqlite3* db;
char *zErrMsg = 0;  // ??

int num_tiers(MAX_TIERS);   // Will be dynamic.
int num_threads(MAX_THREADS);   // Will be dynamic.
int current_thread(1);
int num_threads_fired(0);
bool need_reload(false);

bool fire_object( int id );
void* thread_loop( void* thread_id );
void start_threads();
void get_timestamp( double& out_time );
bool run_tier( int tier );
void reload_handler( int sig_num );
void load_objects( int initial_load );
void load_types( int initial_load );

void run_trad4() {

    signal(SIGUSR1, reload_handler);

    sqlite3_open(getenv("TRAD4_DB"), &db);

    for ( int i = 0 ; i < MAX_OBJECTS+1 ; i++ )
    {
        obj_loc[i] = 0;
    }

    for ( int i = 0 ; i < MAX_TYPES+1 ; i++ )
    {
        object_type_struct[i] = 0;
    }

    load_types( 1 );

    for ( int i=1 ; i < MAX_TIERS+1 ; i++ )
    {
        tier_manager[i][0]=1;
    }

    load_objects( 1 );

    for ( int i = 0 ; i < MAX_OBJECTS+1 ; i++ )
    {
        if ( obj_loc[i] )
        {
            tier_manager[((object_header*)obj_loc[i])->tier][tier_manager[((object_header*)obj_loc[i])->tier][0]] = i;
            tier_manager[((object_header*)obj_loc[i])->tier][0]++;
        }
    }

    start_threads();

    sleep(1);

    cout << endl;

    for ( int tier=1 ; tier <= num_tiers ; tier++ )
    {
        std::cout << "Checking tier " << tier << ". Num objs this tier: " << tier_manager[tier][0] - 1 << std::endl; 
    }

    if ( 1 ) 
    {
        cout << endl << "Forcing reload.." << endl << endl;
        sleep(1);

        load_objects( 0 );
    }

    double start_time;
    double end_time;
    double tier_start_time; 
    double tier_end_time;
    
    while (1)
    {
        get_timestamp( start_time );
        get_timestamp( tier_start_time );

        if ( run_tier( 1 ) )
        {
            get_timestamp( tier_end_time );

            cout << setprecision(6) << "Tier " << 1 << " run in " << tier_end_time - tier_start_time << endl << endl;

            for ( int tier=2 ; tier < num_tiers+1 ; tier++ )
            {
                if ( tier_manager[tier][0] <= 1 )
                {
                    continue;
                }

                get_timestamp( tier_start_time );

                cout << setprecision(6) << "Tier " << tier << " running." << endl;
        
                run_tier( tier );

                get_timestamp( tier_end_time );


                cout << setprecision(6) << "Tier " << tier << " complete in " << tier_end_time - tier_start_time << endl;

            }

            get_timestamp( end_time );

            cout << endl << "All tiers complete in " << end_time-start_time << endl << endl;

        }
        else
        {
            usleep(500);
        }

        if ( need_reload )
        {
            need_reload = false;
    
            load_types( 0 );
    
            load_objects( 0 );
        }

    }
}

void get_timestamp( double& out_time )
{
    timeval tim;
    gettimeofday(&tim, NULL);
    out_time = tim.tv_sec + ( tim.tv_usec / 1000000.0 );

}

bool run_tier( int tier ) {

    bool tier_fired(false);

    int num_times_waited_this_tier(0);

    for ( int i=1 ; i <= tier_manager[tier][0] ; i++ )
    {

        //std::cout << "Checking tier " << tier << ". i=" << i << ", num objs this tier: " << tier_manager[tier][0] - 1 << std::endl; 

        if ( obj_loc[tier_manager[tier][i]] )
        {
            //cout << "Calling need_refresh_fpointer for " << tier_manager[tier][i] << endl;

            if ( (*object_type_struct[((object_header*)obj_loc[tier_manager[tier][i]])->type]->need_refresh)(obj_loc, tier_manager[tier][i] ) ) 
            {
                while ( ! fire_object( tier_manager[tier][i] ) )
                {
                    //cout << "Fire object failed due to lack of spare threads. Sleeping master thread." << endl;
                    num_times_waited_this_tier++;
                    usleep(5);
                }

                tier_fired = true;
            }
        }
    }


    // Wait for all the threads to finish with this tier.

    bool thread_still_runnning(true);

    while ( thread_still_runnning )
    {
        thread_still_runnning = false;

        for ( int i=1 ; i <= num_threads ; i++ )
        {
            if ( thread_contoller[i] != 0 )
            {
                thread_still_runnning = true;
                break;
            }
        }

        if ( thread_still_runnning )
        {
            usleep(50);
        }
    }

    if ( tier_fired ) 
    {
        cout << "Waited " << num_times_waited_this_tier << " this tier." << endl;
    }

    return tier_fired;
}

bool fire_object( int id )
{
    //std::cout << "fire_object " << id << std::endl;

    bool fired(false);

    for ( int i=current_thread ; i <= num_threads ; i++ )
    {
// Something broken here?
        if ( thread_contoller[i] == 0 )
        {
            ((object_header*)obj_loc[id])->status = RUNNING;
            thread_contoller[i] = id;
            fired = true;
            num_threads_fired++;
            break;
        }

        current_thread++;

        if ( current_thread > num_threads )
            current_thread=1;
    }

    return fired;
}

void set_timestamp( obj_loc_t obj_loc, int id )
{
    //for ( int i=0 ; i < 1000000000 ; i++ );   // Simulate long calculations

    timeval tim;
    gettimeofday( &tim, NULL );

    double timestamp_double = tim.tv_sec + (tim.tv_usec / 1000000.0);
    long long timestamp = (long long)(timestamp_double * 1000000 );

    //std::cout << "setting timestamp: " << timestamp << std::endl;

    *(int*)obj_loc[id] = timestamp;

    ((object_header*)obj_loc[id])->status = STOPPED;
}

void* thread_loop( void* thread_id ) 
{

    cout << "Starting thread " << (int)thread_id << endl;

    bool thread_fired(false);

    while (1) {

        //cout << "thread_contoller[(int)thread_id] = " << thread_contoller[(int)thread_id] << endl;

        if ( thread_contoller[(int)thread_id] != 0 )
        {

            //cout << "Thread #" << (int)thread_id << " working on obj id: " << thread_contoller[(int)thread_id] << endl;

            (*object_type_struct[((object_header*)obj_loc[thread_contoller[(int)thread_id]])->type]->calculate)(obj_loc, thread_contoller[(int)thread_id] );

            set_timestamp( obj_loc, thread_contoller[(int)thread_id] );

            //cout << "Thread #" << (int)thread_id << " done." << endl;
            thread_fired=true;

            thread_contoller[(int)thread_id] = 0;

            usleep(50);
        }
        else
        {
            usleep(500);
        }
    }
}

void start_threads()
{
    for ( int i=1 ; i <= num_threads ; i++ )
    {
        pthread_t t1;

        if ( pthread_create(&t1, NULL, thread_loop, (void *)i) != 0 ) {
            cout << "pthread_create() error" << endl;
            abort();
        }
    }
}

void reload_handler( int sig_num )
{
    signal(SIGUSR1, reload_handler);

    cout << "reload_handler" << endl;
    need_reload = true;
}

static int load_types_callback(void *NotUsed, int argc, char **row, char **azColName)
{
    char *error;

    int obj_num = atoi(row[0]);
    char* name = row[1];

    if ( object_type_struct[obj_num] == 0 )
    {
        cout << "Creating new type " << name << ", type id: " << obj_num << ", tier: " << atoi(row[2]) << endl;

        object_type_struct[obj_num] = new object_type_struct_t;
    }
    else 
    {
        cout << "Reloading type " << name << ", id: " << obj_num << ", tier: " << atoi(row[2]) << endl;

        dlclose(object_type_struct[obj_num]->lib_handle);
        object_type_struct[obj_num]->constructor_fpointer = 0;
        object_type_struct[obj_num]->need_refresh = 0;
        object_type_struct[obj_num]->calculate = 0;
        object_type_struct[obj_num]->load_objects = 0;
    }

    ostringstream lib_name;
    lib_name << getenv("APP_ROOT") << "/lib/lib" << name << ".so";

    (object_type_struct[obj_num])->lib_handle = dlopen (lib_name.str().c_str(), RTLD_LAZY);
    if (!object_type_struct[obj_num]->lib_handle) {
        fputs (dlerror(), stderr);
        exit(1);
    }

    object_type_struct[obj_num]->constructor_fpointer = dlsym(object_type_struct[obj_num]->lib_handle, "constructor");
    if ((error = dlerror()) != NULL)  {
        fputs(error, stderr);
        exit(1);
    }

    object_type_struct[obj_num]->need_refresh = (need_refresh_fpointer)dlsym(object_type_struct[obj_num]->lib_handle, "need_refresh");
    if ((error = dlerror()) != NULL)  {
        fputs(error, stderr);
        exit(1);
    }

    object_type_struct[obj_num]->calculate = (calculate_fpointer)dlsym(object_type_struct[obj_num]->lib_handle, "calculate");
    if ((error = dlerror()) != NULL)  {
        fputs(error, stderr);
        exit(1);
    }

    object_type_struct[obj_num]->load_objects = (load_objects_fpointer)dlsym(object_type_struct[obj_num]->lib_handle, "load_objects");
    if ((error = dlerror()) != NULL)  {
        fputs(error, stderr);
        exit(1);
    }

    return 0;
}

void load_types( int initial_load )
{

    std::ostringstream dbstream;

    if ( initial_load ) 
        dbstream << "select type_id, name, tier from object_types";
    else
        dbstream << "select type_id, name, tier from object_types where need_reload=1";
        

    if( sqlite3_exec(db, dbstream.str().c_str(), load_types_callback, 0, &zErrMsg) != SQLITE_OK ){
        fprintf(stderr, "SQL error: %s\n", zErrMsg);
        sqlite3_free(zErrMsg);
    }
}

static int load_objects_callback(void* initial_load_v, int argc, char **row, char **azColName)
{
    int initial_load = *((int*)initial_load_v);

    (*object_type_struct[atoi(row[0])]->load_objects)( obj_loc, initial_load );

    return 0;
}

void load_objects( int initial_load )
{
    std::ostringstream dbstream;
    dbstream << "select type_id, tier from object_types";

    if( sqlite3_exec(db, dbstream.str().c_str(), load_objects_callback, (void*)&initial_load, &zErrMsg) != SQLITE_OK ){
        fprintf(stderr, "SQL error: %s\n", zErrMsg);
        sqlite3_free(zErrMsg);
    }
}