
// GENERATED BY TRAD4 

// Please see the comment at the top of gunfighter/gen/objects/gunfighter_macros.h
//  to see what's in-scope.

#include <iostream>

#include "gunfighter_wrapper.c"

using namespace std;

int calculate_gunfighter( obj_loc_t obj_loc, int id )
{
    gunfighter_killed_someone = 0;
    gunfighter_killed_whom = 0;

    if ( ! object_init(id) || monitor_reset )
    {
        gunfighter_alive = 1;
    }
    else 
    {

        if ( gunfighter1_alive ) 
        {
            if ( gunfighter1_killed_someone )
            {
                if ( gunfighter1_killed_whom == id )
                {
                    cout << object_name( id ) << " is dead." << endl;
                    gunfighter_alive = 0;
                }
            }
        }


        if ( gunfighter2_alive ) 
        {
            if ( gunfighter2_killed_someone )
            {
                if ( gunfighter2_killed_whom == id )
                {
                    cout << object_name( id ) << " is dead." << endl;
                    gunfighter_alive = 0;
                }
            }
        }

        if ( gunfighter_alive )
        {
            if ( gunfighter1_alive && gunfighter2_alive )
            {
                gunfighter_killed_whom = (( rand() / (double)RAND_MAX ) > 0.5 ) ? gunfighter_gunfighter1 : gunfighter_gunfighter2;
            }
            else if ( gunfighter1_alive )
            {
                gunfighter_killed_whom = gunfighter_gunfighter1;
            }
            else if ( gunfighter2_alive )
            {
                gunfighter_killed_whom = gunfighter_gunfighter2;
            }

            gunfighter_killed_someone = (( rand() / (double)RAND_MAX ) <= gunfighter_kill_prob );
/*
            if (( rand() / (double)RAND_MAX ) > 0.5 )
            {   
                gunfighter_killed_whom = gunfighter_gunfighter1;
            }
            else
            {
                gunfighter_killed_whom = 2; //gunfighter_gunfighter2;
            }
*/

    cout << object_name(id) << " shot at " << object_name( gunfighter_killed_whom ) << " and kill: " << gunfighter_killed_someone << endl;

        }

    }

    return 1;
}
