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

//void* obj_loc[NUM_OBJECTS+1];
obj_loc_t obj_loc;
tier_manager_t tier_manager;

int thread_contoller[NUM_THREADS+1];
//int tier_manager[NUM_TIERS+1][NUM_OBJECTS+1];

bool fire_object( int id );
void* thread_loop( void* thread_id );
void start_threads();
void get_timestamp( int& sec, int& mil );
bool run_tier( int tier );

bool need_reload(false);
void reload_handler( int sig_num );

void load_all();
//extern void reload_objects();

int current_thread(1);
int num_threads_fired(0);
int timestamp_offset(0);

void create_types();

typedef void (*calculate_fpointer)(obj_loc_t obj_loc, int i);
typedef int (*need_refresh_fpointer)(obj_loc_t obj_loc, int id );
typedef void (*load_objects_fpointer)(obj_loc_t obj_loc, tier_manager_t tier_manager );

typedef struct {
    void* lib_handle;
    calculate_fpointer calculate;
    need_refresh_fpointer need_refresh;
    load_objects_fpointer load_objects;
    void* constructor_fpointer;
} type_struct;

type_struct* my_type_struct[15];


int main() {

    signal(SIGUSR1, reload_handler);

create_types();

tier_manager[1][0]=1;
tier_manager[2][0]=1;
tier_manager[3][0]=1;
tier_manager[4][0]=1;
tier_manager[5][0]=1;

    timeval time;
    gettimeofday( &time, NULL );
    timestamp_offset = ( time.tv_sec / 1000000 ) * 1000000;

    load_all();

    start_threads();

    sleep(1);

    cout << endl;

    for ( int tier=1 ; tier <= NUM_TIERS ; tier++ )
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

            for ( int tier=2 ; tier < NUM_TIERS+1 ; tier++ )
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

            if ( (*my_type_struct[ ((object_header*)obj_loc[tier_manager[tier][i]])->type ]->need_refresh)(obj_loc, tier_manager[tier][i] ) ) 
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

        for ( int i=1 ; i <= NUM_THREADS ; i++ )
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

    for ( int i=current_thread ; i <= NUM_THREADS ; i++ )
    {
        if ( thread_contoller[i] == 0 )
        {
            ((object_header*)obj_loc[id])->status = RUNNING;
            thread_contoller[i] = id;
            fired = true;
            num_threads_fired++;
            break;
        }

        current_thread++;

        if ( current_thread > NUM_THREADS )
            current_thread=1;
    }

    return fired;
}

void set_timestamp( int id )
{
//    for ( int i=0 ; i < 1000000000 ; i++ );   // Simulate long calculations

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

            (*my_type_struct[ ((object_header*)obj_loc[thread_contoller[(int)thread_id]])->type ]->calculate)(obj_loc, thread_contoller[(int)thread_id] );

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
    for ( int i=1 ; i <= NUM_THREADS ; i++ )
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

void create_types()
{

    MYSQL_RES *result;
    MYSQL_ROW row;
    MYSQL mysql;

    mysql_init(&mysql);

    if (!mysql_real_connect(&mysql,"localhost", "root", NULL,getenv("INSTANCE"),0,NULL,0))
    {
        std::cout << __LINE__ << " "  << mysql_error(&mysql) << std::endl;
    }

    std::ostringstream dbstream;
    dbstream << "select type_id, tier from types where need_reload=1";

    if(mysql_query(&mysql, dbstream.str().c_str()) != 0) {
        std::cout << __LINE__ << ": " << mysql_error(&mysql) << std::endl;
        exit(0);
    }

    result = mysql_use_result(&mysql);

    while (( row = mysql_fetch_row(result) ))
    {



        char *error;

    //    typedef void (*hello_t)();

        int obj_num = atoi(row[0]);
cout << "Type id: " << obj_num << endl;

        my_type_struct[obj_num] = new type_struct;

        ostringstream lib_name;
        lib_name << "/home/steve/src/" << getenv("INSTANCE") << "/lib/t4lib_" << obj_num;

        (my_type_struct[obj_num])->lib_handle = dlopen (lib_name.str().c_str(), RTLD_LAZY);
        if (!my_type_struct[obj_num]->lib_handle) {
            fputs (dlerror(), stderr);
            exit(1);
        }

        my_type_struct[obj_num]->constructor_fpointer = dlsym(my_type_struct[obj_num]->lib_handle, "constructor");
        if ((error = dlerror()) != NULL)  {
            fputs(error, stderr);
            exit(1);
        }

        my_type_struct[obj_num]->need_refresh = (need_refresh_fpointer)dlsym(my_type_struct[obj_num]->lib_handle, "need_refresh");
        if ((error = dlerror()) != NULL)  {
            fputs(error, stderr);
            exit(1);
        }

        my_type_struct[obj_num]->calculate = (calculate_fpointer)dlsym(my_type_struct[obj_num]->lib_handle, "calculate");
        if ((error = dlerror()) != NULL)  {
            fputs(error, stderr);
            exit(1);
        }

        my_type_struct[obj_num]->load_objects = (load_objects_fpointer)dlsym(my_type_struct[obj_num]->lib_handle, "load_objects");
        if ((error = dlerror()) != NULL)  {
            fputs(error, stderr);
            exit(1);
        }

    }

    mysql_free_result(result);

}

void load_all() 
{
/*
    MYSQL_RES *result;
    MYSQL_ROW row;
    MYSQL mysql;

    mysql_init(&mysql);

    if (!mysql_real_connect(&mysql,"localhost", "root", NULL,getenv("INSTANCE"),0,NULL,0))
    {
        std::cout << __LINE__ << " "  << mysql_error(&mysql) << std::endl;
    }

    std::ostringstream dbstream;
    dbstream << "select t.type_id, tier from types where need_reload=1";

    if(mysql_query(&mysql, dbstream.str().c_str()) != 0) {
        std::cout << __LINE__ << ": " << mysql_error(&mysql) << std::endl;
        exit(0);
    }

    result = mysql_use_result(&mysql);

    while (( row = mysql_fetch_row(result) ))
    {
*/

//        int obj_num = atoi(row[0]);



        (*my_type_struct[1]->load_objects)(obj_loc, tier_manager );
        (*my_type_struct[2]->load_objects)(obj_loc, tier_manager );
        (*my_type_struct[3]->load_objects)(obj_loc, tier_manager );
        (*my_type_struct[4]->load_objects)(obj_loc, tier_manager );
        (*my_type_struct[5]->load_objects)(obj_loc, tier_manager );
/*
        (*my_type_struct[6]->load_objects)(obj_loc, tier_manager );
        (*my_type_struct[7]->load_objects)(obj_loc, tier_manager );
        (*my_type_struct[8]->load_objects)(obj_loc, tier_manager );
        (*my_type_struct[9]->load_objects)(obj_loc, tier_manager );
        (*my_type_struct[10]->load_objects)(obj_loc, tier_manager );
        (*my_type_struct[11]->load_objects)(obj_loc, tier_manager );
*/

 //   }

}
