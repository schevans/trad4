
// GENERATED BY TRAD4 

// Please see the comment at the top of test_app/gen/objects/tier2_macros.h
//  to see what's in-scope.

#include <iostream>

#include "tier2_wrapper.c"

using namespace std;

int calculate_tier2( obj_loc_t obj_loc, int id )
{

//cout << "tier2_struct3_nested_scalar_my_struct1_x: " << tier2_struct3_nested_scalar_my_struct1_x << endl;

    T4_TEST( multi_struct_my_outers_ig( 0 ), 99 );
    T4_TEST( multi_struct_my_outers_ig( 1 ), 199 );
    T4_TEST( multi_struct_my_outers_ig( 2 ), 299 );
    T4_TEST( multi_struct_my_outers_ig( 3 ), 399 );

    T4_TEST( multi_struct_my_outers_fr( 0 ), 9.9 );
    T4_TEST( multi_struct_my_outers_fr( 1 ), 19.9 );
    T4_TEST( multi_struct_my_outers_fr( 2 ), 29.9 );
    T4_TEST( multi_struct_my_outers_fr( 3 ), 39.9 );

    T4_TEST( multi_struct_my_outers_my_inner_ms_d(0,1), 1 );
    T4_TEST( multi_struct_my_outers_my_inner_ms_d(3,2), 32 );

    T4_TEST( multi_struct_my_outers_my_inner_ms_ha(0,0,1), 0.1 );
    T4_TEST( multi_struct_my_outers_my_inner_ms_ha(3,2,7), 32.7 );

    T4_TEST( tier1_double_array[ 2 ], 3.14 );
    T4_TEST( tier1_struct_scalar_dates[ 2 ], 5002 );
    T4_TEST( tier1_int_out, 15003 );

    tier2_p_int = tier1_int_out - 38;
 

/*
cout << "tier2:" << endl;
cout << "tier2_tier1:" << tier2_tier1 << endl;
cout << "tier1_int1:" << tier1_int1 << endl;
cout << "tier1_int2:" << tier1_int2 << endl;
//cout << "tier1_struct_scalar:" << tier1_struct_scalar << endl;
cout << "tier1_struct_scalar_rates( 3 ):" << tier1_struct_scalar_rates( 3 ) << endl;
cout << "tier1_struct_scalar_dates( 3 ):" << tier1_struct_scalar_dates( 3 ) << endl;
cout << "tier1_double_array( 8 ):" << tier1_double_array( 8 ) << endl;
cout << "tier1_int_out:" << tier1_int_out << endl;
cout << "tier1_bool_array( 14 ):" << tier1_bool_array( 14 ) << endl;
//cout << "tier1_struct_vec( 2 ):" << tier1_struct_vec( 2 ) << endl;
cout << "tier1_struct_vec_x( 2 ):" << tier1_struct_vec_x( 2 ) << endl;
cout << "tier1_struct_vec_y( 2 ):" << tier1_struct_vec_y( 2 ) << endl;
cout << "tier2_double1:" << tier2_double1 << endl;
cout << "tier2_p_int:" << tier2_p_int << endl;
*/

    return 1;
}

