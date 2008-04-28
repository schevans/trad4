
#include <iostream>

#include "kertn_d2_wrapper.c"

using namespace std;

void calculate_kertn_d2( obj_loc_t obj_loc, int id )
{
    DEBUG( "calculate_kertn_d2( " << id << ")" )

    kertn_d2_KerTN_pd2 = rate_trade_KerT * bs_delta_N_pd2;

    kertn_d2_KerTN_md2 = rate_trade_KerT * bs_delta_N_md2;
}

