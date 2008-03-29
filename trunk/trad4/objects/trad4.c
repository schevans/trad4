// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk
//

#include <iostream>
#include <pthread.h>
#include <sys/time.h>

#include "trad4.h"

using namespace std;

void* obj_loc[NUM_OBJECTS+1];
int thread_contoller[NUM_THREADS+1];

bool fire_object( int id );
void* thread_loop( void* thread_id );
void start_threads();

extern void load_all();

int tier_manager[NUM_TIERS+1][NUM_OBJECTS+1];

int current_thread(1);

int num_threads_fired(0);

int main() {

    load_all();

    start_threads();

    sleep(1);

    int total_sec;
    int total_mil;

    while (1)
    {
        bool tier1_fired(false);
        for ( int tier=1 ; tier < NUM_TIERS+1 ; tier ++ )
        {

            int num_times_waited_this_tier(0);

            int start_sec;
            int start_mil;

            if ( tier != 1 )
            {
                timeval time;
                gettimeofday( &time, NULL );
                start_sec = time.tv_sec;
                start_mil = time.tv_usec;

                cout << "Tier " << tier << " running." << endl;
            }

            if ( tier == 2 )
            {
                timeval time;
                gettimeofday( &time, NULL );
                total_sec = time.tv_sec;
                total_mil = time.tv_usec;
            }

            for ( int i=1 ; i <= tier_manager[tier][0] ; i++ )
            {
                //std::cout << "Checking tier " << tier << ". i=" << i << ", num objs this tier: " << tier_manager[tier][0] << std::endl; 

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

                        tier1_fired = true;
                    }
                }
            }

            if ( tier == 1 && tier1_fired == false )
            {
//                usleep(500);
                break;
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

                timeval time;
                gettimeofday( &time, NULL );
                int end_sec = time.tv_sec;
                int end_mil = time.tv_usec;

            cout << "Tier " << tier << " complete in " << end_sec - start_sec << "s " << end_mil - start_mil << "m. Waited " << num_times_waited_this_tier << " times this tier." << endl << endl;

            if ( tier == 4 )
            {
                timeval time;
                gettimeofday( &time, NULL );

                int end_sec = time.tv_sec - total_sec;
                int end_mil = time.tv_usec - total_mil;

                if ( end_mil < 0 )
                {
                    end_sec = end_sec + 1;
                    end_mil = end_mil + 1000000;
                }

                cout << "Total time to recalc " << num_threads_fired << " objects: " << end_sec << "s, " << end_mil << "m." << endl << endl << endl;

                total_sec = time.tv_sec;
                total_mil = time.tv_usec;
                num_threads_fired = 0;

            }

            if ( tier == 1 )
            {
                usleep(500);
            }

            //sleep(1);
        }
    }
}

bool fire_object( int id )
{
    //std::cout << "fire_object " << id << std::endl;
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

//std::cout << "sec: " << sec << ", mil: " << mil << std::endl;

    int timestamp = (( sec - 1206000000 ) * 1000 ) + ( mil / 1000 );

    //std::cout << "setting timestamp: " << timestamp << std::endl;

    *(int*)obj_loc[id] = timestamp;

    ((object_header*)obj_loc[id])->status = STOPPED;
}

void* thread_loop( void* thread_id ) 
{

    cout << "Starting thread " << (int)thread_id << endl;

    bool thread_fired(false);

    while (1) {

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

