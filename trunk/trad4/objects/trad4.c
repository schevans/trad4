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

#include "mysql/mysql.h"

#include "trad4.h"

using namespace std;

obj_loc_t obj_loc;
tier_manager_t tier_manager;
int thread_contoller[MAX_THREADS+1];
object_type_struct_t* object_type_struct[MAX_TYPES+1];

int num_tiers(MAX_TIERS);   // Will be dynamic.
int num_threads(MAX_THREADS);   // Will be dynamic.
int current_thread(1);
int num_threads_fired(0);
int timestamp_offset(0);
bool need_reload(false);

bool fire_object( int id );
void* thread_loop( void* thread_id );
void start_threads();
void get_timestamp( int& sec, int& mil );
bool run_tier( int tier );
void reload_handler( int sig_num );
void load_all();
void create_types();

#include <sqlite3.h>

sqlite3* db;
char *zErrMsg = 0;  // ??


static int mycounter(0);

static int callback(void *NotUsed, int argc, char **argv, char **azColName){
  int i;
  for(i=0; i<argc; i++){
    //printf("%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL");
  }
    mycounter++;
//  printf("%d\n", mycounter);
  return 0;
}

int sqlite_test()
{


    char* sql = "select o.name, b.maturity_date from object o, bond b where o.id=b.id and need_reload=0";

    int rc = sqlite3_exec(db, sql, callback, 0, &zErrMsg);

    if( rc!=SQLITE_OK ){
        fprintf(stderr, "SQL error: %s\n", zErrMsg);
        sqlite3_free(zErrMsg);
    }

  printf("done %d\n", mycounter);
    sqlite3_close(db);
    return 0;


}

int main() {

    signal(SIGUSR1, reload_handler);

    sqlite3_open(getenv("TRAD4_DB"), &db);

    for ( int i = 0 ; i < MAX_OBJECTS+1 ; i++ )
    {
        obj_loc[i] = 0;
    }

    create_types();

//int i = obj_loc;

 DBG 
 DBG 
/* 
    obj_loc = new unsigned char[MAX_OBJECTS+1];


cout << "3: obj_loc[2]: " << obj_loc[2] << endl;
*/
    for ( int i=1 ; i < MAX_TIERS+1 ; i++ )
    {
        tier_manager[i][0]=1;
    }

    timeval time;
    gettimeofday( &time, NULL );
    timestamp_offset = ( time.tv_sec / 1000000 ) * 1000000;

    load_all();


    for ( int i = 0 ; i < MAX_OBJECTS+1 ; i++ )
    {
        if ( obj_loc[i] )
        {

        //tier_manager[4][tier_manager[4][0]] = id;
        //tier_manager[4][0]++;

int tier = ((object_header*)obj_loc[i])->tier;

            tier_manager[tier][tier_manager[tier][0]] = i;
            tier_manager[tier][0]++;
        }
    }
DBG

//cout << "FF@ " << ((object_header*)obj_loc[3])->status << endl;

        tier_manager[4][tier_manager[4][0]] = 4;
        tier_manager[4][0]++;


    start_threads();

    sleep(1);

    cout << endl;

    for ( int tier=1 ; tier <= num_tiers ; tier++ )
    {
        std::cout << "Checking tier " << tier << ". Num objs this tier: " << tier_manager[tier][0] - 1 << std::endl; 
    }

    int total_start_sec;
    int total_start_mil;
    int total_end_sec;
    int total_end_mil;
    int start_sec;
    int start_mil;
    int end_sec;
    int end_mil;

    while (1)
    {

        get_timestamp( start_sec, start_mil );

        if ( run_tier( 1 ) )
        {
            get_timestamp( end_sec, end_mil );

            cout << "Tier " << 1 << " run in " << end_sec - start_sec << "s " << end_mil - start_mil << "m." << endl << endl;

            total_start_sec = start_sec;
            total_start_mil = start_mil;

            for ( int tier=2 ; tier < num_tiers+1 ; tier++ )
            {
                get_timestamp( start_sec, start_mil );

                cout << "Tier " << tier << " running." << endl;
        
                run_tier( tier );

                get_timestamp( end_sec, end_mil );

                int elapsed_sec = end_sec - start_sec;
                int elapsed_mil = end_mil - start_mil;
                
                if ( elapsed_sec < 0 )
                {
                    elapsed_sec = end_sec + 1;
                    elapsed_mil = elapsed_mil + 1000000;
                }

                cout << "Tier " << tier << " complete in " << elapsed_sec << "s " << elapsed_mil << "ms." << endl << endl;

            }

            get_timestamp( total_end_sec, total_end_mil );

            int total_elapsed_sec = total_end_sec - total_start_sec;
            int total_elapsed_mil = total_end_mil - total_start_mil;

            if ( total_elapsed_sec < 0 )
            {
                total_elapsed_sec = total_end_sec + 1;
                total_elapsed_mil = total_elapsed_mil + 1000000;
            }

            cout << endl << "All tiers complete in " << total_elapsed_sec << "s " << total_elapsed_mil << "ms." << endl << endl;

        }
        else
        {
            usleep(500);
        }

        if ( need_reload )
        {
            need_reload = false;
            load_all();
        }

    }
}

void get_timestamp( int& sec, int& mil )
{
    timeval time;
    gettimeofday( &time, NULL );
    sec = time.tv_sec;
    mil = time.tv_usec;
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

            if ( (*object_type_struct[ ((object_header*)obj_loc[tier_manager[tier][i]])->type ]->need_refresh)(obj_loc, tier_manager[tier][i] ) ) 
//            if ( (*((object_header*)obj_loc[tier_manager[tier][i]])->need_refresh_fpointer)(obj_loc, tier_manager[tier][i]) )
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
    std::cout << "fire_object " << id << std::endl;

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

    timeval time;
    gettimeofday( &time, NULL );
    int sec = time.tv_sec;
    int mil = time.tv_usec;

    int timestamp = (( sec - timestamp_offset ) * 1000 ) + ( mil / 1000 );

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

            cout << "Thread #" << (int)thread_id << " working on obj id: " << thread_contoller[(int)thread_id] << endl;

            (*object_type_struct[ ((object_header*)obj_loc[thread_contoller[(int)thread_id]])->type ]->calculate)(obj_loc, thread_contoller[(int)thread_id] );

            set_timestamp( obj_loc, thread_contoller[(int)thread_id] );

            cout << "Thread #" << (int)thread_id << " done." << endl;
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

static int create_types_callback(void *NotUsed, int argc, char **row, char **azColName)
{
    char *error;

    int obj_num = atoi(row[0]);
    char* name = row[1];

    cout << "Name: " << name << ", type id: " << obj_num << ", tier: " << atoi(row[2]) << endl;

    object_type_struct[obj_num] = new object_type_struct_t;

    ostringstream lib_name;
    lib_name << getenv("INSTANCE_ROOT") << "/lib/lib" << name << ".so";

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

void create_types()
{

    std::ostringstream dbstream;
    dbstream << "select type_id, name, tier from object_types where need_reload=1";

    if( sqlite3_exec(db, dbstream.str().c_str(), create_types_callback, 0, &zErrMsg) != SQLITE_OK ){
        fprintf(stderr, "SQL error: %s\n", zErrMsg);
        sqlite3_free(zErrMsg);
    }
}

static int load_all_callback(void *NotUsed, int argc, char **row, char **azColName)
{
    (*object_type_struct[atoi(row[0])]->load_objects)(obj_loc, tier_manager );

    return 0;
}

void load_all() 
{
    std::ostringstream dbstream;
    dbstream << "select type_id, tier from object_types where need_reload=1";

    if( sqlite3_exec(db, dbstream.str().c_str(), load_all_callback, 0, &zErrMsg) != SQLITE_OK ){
        fprintf(stderr, "SQL error: %s\n", zErrMsg);
        sqlite3_free(zErrMsg);
    }
}
