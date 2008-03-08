
#include "trad4.h"
#include "currency_curves.h"
#include "interest_rate_feed.h"

extern void* obj_loc[NUM_OBJECTS+1];

extern void set_timestamp( int id );
extern void* calculate_currency_curves( currency_curves* pub_currency_curves , interest_rate_feed* sub_interest_rate_feed );


void* calculate_currency_curves_wrapper( void* id )
{
    currency_curves* pub_currency_curves = (currency_curves*)obj_loc[(int)id];
    interest_rate_feed* sub_interest_rate_feed = (interest_rate_feed*)obj_loc[pub_currency_curves->interest_rate_feed];

    calculate_currency_curves( pub_currency_curves , sub_interest_rate_feed );

    set_timestamp((int)id);

}

bool currency_curves_need_refresh( int id )
{
    return ( (((object_header*)obj_loc[id])->status == STOPPED ) && ( ( *(int*)obj_loc[id] < *(int*)obj_loc[((currency_curves*)obj_loc[id])->interest_rate_feed] ) ||  0 ));
}
