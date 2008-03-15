
#include "trad4.h"
#include "bond.h"
#include "currency_curves.h"

extern void* obj_loc[NUM_OBJECTS+1];

extern void set_timestamp( int id );
extern void* calculate_bond( bond* pub_bond , currency_curves* sub_currency_curves );


void* calculate_bond_wrapper( void* id )
{
    bond* pub_bond = (bond*)obj_loc[(int)id];
    currency_curves* sub_currency_curves = (currency_curves*)obj_loc[pub_bond->currency_curves];

    calculate_bond( pub_bond , sub_currency_curves );

    set_timestamp((int)id);

}

bool bond_need_refresh( int id )
{
    return ( (((object_header*)obj_loc[id])->status == STOPPED ) && ( ( *(int*)obj_loc[id] < *(int*)obj_loc[((bond*)obj_loc[id])->currency_curves] ) ||  0 ));
}
