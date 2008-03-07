

#include <iostream>

#include "trad4.h"
#include "repo_trade.h"
#include "bond.h"
#include "currency_curves.h"

extern void* obj_loc[NUM_OBJECTS+1];

extern void set_timestamp( int id );
extern void* calculate_repo_trade( repo_trade* pub_repo_trade , bond* sub_bond , currency_curves* sub_currency_curves );

using namespace std;

void* calculate_repo_trade_wrapper( void* id )
{
    repo_trade* pub_repo_trade = (repo_trade*)obj_loc[(int)id];
    bond* sub_bond = (bond*)obj_loc[pub_repo_trade->bond];
    currency_curves* sub_currency_curves = (currency_curves*)obj_loc[pub_repo_trade->currency_curves];

    calculate_repo_trade( pub_repo_trade , sub_bond , sub_currency_curves );

    set_timestamp((int)id);

}

bool repo_trade_need_refresh( int id )
{
#if 0
cout << "\trepo_trade_need_refresh( " << id << ")" << endl;
cout << "\tstatus=" << ((object_header*)obj_loc[id])->status
        << ", my_ts=" <<  *(int*)obj_loc[id] 
        << ", b_ts=" << *(int*)obj_loc[((repo_trade*)obj_loc[id])->bond]
        << ", c_ts=" << *(int*)obj_loc[((repo_trade*)obj_loc[id])->currency_curves]
        << endl;
#endif

    return ( (((object_header*)obj_loc[id])->status == STOPPED ) && (( *(int*)obj_loc[id] < *(int*)obj_loc[((repo_trade*)obj_loc[id])->bond] ) || (( *(int*)obj_loc[id] < *(int*)obj_loc[((repo_trade*)obj_loc[id])->currency_curves] ) ||  0 )));
}
