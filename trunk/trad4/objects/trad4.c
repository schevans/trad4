// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk
//

#include <iostream>
#include <pthread.h>
#include <sys/time.h>

#include "trad4.h"

// Temp for proto
#include "interest_rate_feed.h"

using namespace std;

void* obj_loc[NUM_OBJECTS+1];

void fire_object( int id );
void run();

// For prototype only 
//  Mimics the IR feed.
void bump_rates();

// This is only ever called from the object threads, as it's a writer.
void set_timestamp( int id );

extern void load_all();

int main() {

    load_all();

    // Fire off the feed once and let it terminate. This will populate rate_interpol
    fire_object( 1 );

    run();

}

void fire_object( int id )
{
    pthread_t t1;

    ((object_header*)obj_loc[id])->status = RUNNING;

    if ( pthread_create(&t1, NULL, (*((object_header*)obj_loc[id])->calculator_fpointer), (void *)id) != 0 ) {
        cout << "pthread_create() error" << endl;
        abort();
    }
}

void set_timestamp( int id )
{
    timeval time;
    gettimeofday( &time, NULL );
    int sec = time.tv_sec;
    int mil = time.tv_usec;

    int timestamp = (( sec - 1203000000 ) * 1000 ) + ( mil / 1000 );

    // I know this looks strange but we 'know' the first element in the struct (pointed to
    //  by obj_loc[id]) is an int, regardless of the type of the struct.
    *(int*)obj_loc[id] = timestamp;

    ((object_header*)obj_loc[id])->status = STOPPED;
}

void run()
{
    int bump_rates_counter(1);
    
    while (1) 
    {
        for ( int i=1 ; i <= NUM_OBJECTS ; i++ )
        {
            // First check if the object *has* a need_refresh_fpointer
            //  If it doesn't it's a feed.
            if ( ((object_header*)obj_loc[i])->need_refresh_fpointer )
            {
                // Ok it's a CaclObject. Call the function.
                if ( (*((object_header*)obj_loc[i])->need_refresh_fpointer)(i) )
                {
                    fire_object( i );            
                }
            }

        }

        // Bump rates every few seconds to simulate market moving.
        if ( bump_rates_counter++ % 20000000 == 0 )
        {
            bump_rates();
            fire_object( 1 );
        }

    }
}

// For prototype only - mimics the IR feed.
// In the final version I'll probably put the feed structs in shmem so other processes can write to them.
void bump_rates()
{
    cout << "\nRates bumped" << endl;

    double peturbation = ( rand() / (double)RAND_MAX ) - 0.5;

    for ( int i=0 ; i < 10 ; i++ )      // 10 = INTEREST_RATE_LEN
    {
        ((interest_rate_feed*)obj_loc[1])->rate[i] =+ peturbation;
    }
}

