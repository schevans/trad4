
#include "trad4.h"
#include "interest_rate_feed.h"

extern void* obj_loc[NUM_OBJECTS+1];

extern void set_timestamp( int id );
extern void* calculate_interest_rate_feed( interest_rate_feed* pub_interest_rate_feed );


void* calculate_interest_rate_feed_wrapper( void* id )
{
    interest_rate_feed* pub_interest_rate_feed = (interest_rate_feed*)obj_loc[(int)id];

    calculate_interest_rate_feed( pub_interest_rate_feed );

    set_timestamp((int)id);

}

bool interest_rate_feed_need_refresh( int id )
{
    return ( (((object_header*)obj_loc[id])->status == STOPPED ) && ( *(int*)obj_loc[id] < (((interest_rate_feed*)obj_loc[id])->sub)->last_published ));
}
