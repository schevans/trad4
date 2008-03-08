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


int main() {

    load_all();

    start_threads();

    sleep(1);

    while (1)
    {
        bool tier1_fired(false);

        for ( int tier=1 ; tier < NUM_TIERS+1 ; tier ++ )
        {

            if ( tier != 1 )
                cout << "Tier " << tier << " running." << endl;

            for ( int i=1 ; i < tier_manager[tier][0] ; i++ )
            {
                if ( obj_loc[tier_manager[tier][i]] )
                {
                    //cout << "Calling need_refresh_fpointer for " << tier_manager[tier][i] << endl;

                    if ( (*((object_header*)obj_loc[tier_manager[tier][i]])->need_refresh_fpointer)(tier_manager[tier][i]) )
                    {
                        while ( ! fire_object( tier_manager[tier][i] ) )
                        {
                            cout << "Fire object failed due to lack of spare threads. Sleeping master thread." << endl;
                            sleep(1);
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

            cout << "Tier " << tier << " complete" << endl << endl;

        }
    }
}

bool fire_object( int id )
{
    bool fired(false);

    for ( int i=1 ; i <= NUM_THREADS ; i++ )
    {
        if ( thread_contoller[i] == 0 )
        {
            ((object_header*)obj_loc[id])->status = RUNNING;
            thread_contoller[i] = id;
            fired = true;
            break;
        }
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

    int timestamp = (( sec - 1203000000 ) * 1000 ) + ( mil / 1000 );

    *(int*)obj_loc[id] = timestamp;

    ((object_header*)obj_loc[id])->status = STOPPED;
}

void* thread_loop( void* thread_id ) 
{

    cout << "Starting thread " << (int)thread_id << endl;

    while (1) {

        if ( thread_contoller[(int)thread_id] != 0 )
        {

            cout << "Thread #" << (int)thread_id << " working on obj id: " << thread_contoller[(int)thread_id] << endl;

            (*((object_header*)obj_loc[thread_contoller[(int)thread_id]])->calculator_fpointer)((void*)(thread_contoller[(int)thread_id]));
            thread_contoller[(int)thread_id] = 0;

            cout << "Thread #" << (int)thread_id << " done." << endl;
        }

        usleep(50);
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

