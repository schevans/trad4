
// GENERATED BY TRAD4 

// Please see the comment at the top of test_app/gen/objects/multi_struct_macros.h
//  to see what's in-scope.

#include <iostream>

#include "multi_struct_wrapper.c"

using namespace std;

int calculate_multi_struct( obj_loc_t obj_loc, int id )
{
    T4_TEST( multi_struct_my_outers_ig( 0 ), 99 );
    T4_TEST( multi_struct_my_outers_fr( 3 ), 39.9 );
    T4_TEST( multi_struct_my_outers_my_inner_ms_d(0,1), 1 );
    T4_TEST( multi_struct_my_outers_my_inner_ms_ha(3,2,7), 32.7 );

    return 1;
}
