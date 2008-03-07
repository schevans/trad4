
#include "trad4.h"
#include "outright_trade.h"
#include "bond.h"

extern void* obj_loc[NUM_OBJECTS+1];

extern void set_timestamp( int id );
extern void* calculate_outright_trade( outright_trade* pub_outright_trade , bond* sub_bond );


void* calculate_outright_trade_wrapper( void* id )
{
    outright_trade* pub_outright_trade = (outright_trade*)obj_loc[(int)id];
    bond* sub_bond = (bond*)obj_loc[pub_outright_trade->bond];

    calculate_outright_trade( pub_outright_trade , sub_bond );

    set_timestamp((int)id);

}

bool outright_trade_need_refresh( int id )
{
    return ( (((object_header*)obj_loc[id])->status == STOPPED ) && ( *(int*)obj_loc[id] < *(int*)obj_loc[((outright_trade*)obj_loc[id])->bond] ) ||  0 );
}
