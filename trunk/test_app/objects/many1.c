
// GENERATED BY TRAD4 

// Please see the comment at the top of test_app/gen/objects/many1_macros.h
//  to see what's in-scope.

#include <iostream>

#include "many1_wrapper.c"

using namespace std;

int calculate_many1( obj_loc_t obj_loc, long id )
{
    T4_TEST( many1_d9, 9.0 );
    T4_TEST( many1_my_struct1_x, id );
    T4_TEST( many1_my_struct1_y, id );
    T4_TEST( many1_my_struct1_iz, 35 );

    many1_x_d9 = many1_my_struct1_x * many1_i9;
    many1_y_d9 = many1_my_struct1_y * many1_d9;
    many1_iz_d9 = many1_my_struct1_iz * many1_i9;

//cout << "many1_d9: " << many1_d9 << endl;
//cout << "many1_my_struct1_y: " << many1_my_struct1_y << endl;

    return 1;
}

