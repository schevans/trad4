// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk
//

#include <iostream>
#include <pthread.h>
#include <sys/time.h>

#include "trad4.h"

using namespace std;

void* obj_loc[NUM_OBJECTS+1];

#define NUM_THREADS 10

int thread_contoller[NUM_THREADS+1];

bool fire_object( int id );
void run();

void* thread_loop( void* thread_id );
void start_threads();

// This is only ever called from the object threads, as it's a writer.
void set_timestamp( int id );

extern void load_all();

int main() {

    load_all();

    // Fire off the feed once and let it terminate. This will populate rate_interpol
//    fire_object( 1 );

    start_threads();

sleep(1);

    run();

}

bool fire_object( int id )
{
    //cout << "Firing object " << id << endl;

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

sleep(2);

    timeval time;
    gettimeofday( &time, NULL );
    int sec = time.tv_sec;
    int mil = time.tv_usec;

    int timestamp = (( sec - 1203000000 ) * 1000 ) + ( mil / 1000 );

    *(int*)obj_loc[id] = timestamp;

    ((object_header*)obj_loc[id])->status = STOPPED;
}

void run()
{
    while (1) 
    {
        for ( int i=1 ; i <= NUM_OBJECTS ; i++ )
        {
            if ( obj_loc[i] )
            { 
                //cout << "Calling need_refresh_fpointer for " << i << endl;

                if ( (*((object_header*)obj_loc[i])->need_refresh_fpointer)(i) )
                {
                    while ( ! fire_object( i ) )
                    {
                        cout << "Fire object failed due to lack of spare threads. Sleeping master thread." << endl;
                        sleep(1);
                    }
                }
            }
        }
    }
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

        sleep(1);

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

