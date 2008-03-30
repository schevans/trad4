// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk
//

#include <iostream>
#include <pthread.h>
#include <sys/time.h>
#include <signal.h>

#include "trad4.h"

using namespace std;

void* obj_loc[NUM_OBJECTS+1];
int thread_contoller[NUM_THREADS+1];
int tier_manager[NUM_TIERS+1][NUM_OBJECTS+1];

bool fire_object( int id );
void* thread_loop( void* thread_id );
void start_threads();
void get_timestamp( int& sec, int& mil );
bool run_tier( int tier );

bool need_reload(false);
void reload_handler( int sig_num );

extern void load_all();
extern void reload_objects();

int current_thread(1);
int num_threads_fired(0);
int timestamp_offset(0);



int main() {

    signal(SIGUSR1, reload_handler);

    timeval time;
    gettimeofday( &time, NULL );
    timestamp_offset = ( time.tv_sec / 1000000 ) * 1000000;

    load_all();

    start_threads();

    sleep(1);

    cout << endl;

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
            reload_objects();
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

            if ( (*((object_header*)obj_loc[tier_manager[tier][i]])->need_refresh_fpointer)(tier_manager[tier][i]) )
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

            //cout << "Thread #" << (int)thread_id << " working on obj id: " << thread_contoller[(int)thread_id] << endl;

            (*((object_header*)obj_loc[thread_contoller[(int)thread_id]])->calculator_fpointer)((void*)(thread_contoller[(int)thread_id]));

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
