
// GENERATED BY TRAD4 

// Please see the comment at the top of test_app/gen/objects/agg_many1_macros.h
//  to see what's in-scope.

#include <iostream>

#include "agg_many1_wrapper.c"

using namespace std;

int calculate_agg_many1( obj_loc_t obj_loc, int id )
{
    for ( int i = 0 ; i < NUM_MANY1 ; i++ ) 
    {
        agg_many1_agg_struct1_x = agg_many1_agg_struct1_x + many1_array_x_d9( i );
        agg_many1_agg_struct1_y = agg_many1_agg_struct1_y + many1_array_y_d9( i );
        agg_many1_agg_struct1_iz = agg_many1_agg_struct1_iz + many1_array_iz_d9( i );

        T4_TEST( agg_many1_many1_array[i], many1_array_my_struct1_x(i) );
        T4_TEST( many1_array_my_struct1_y(i), many1_array_my_struct1_x(i) );
        T4_TEST( many1_array_iz_d9( i ), 315 );
/*
        cout << "agg_many1_many1_array( " << i << " ): " << agg_many1_many1_array(i) << endl;
        cout << "many1_array_d9( i ): " << many1_array_d9(i) << endl;
        cout << "many1_array_my_struct1_x( i ): " << many1_array_my_struct1_x(i) << endl;
        cout << "many1_array_x_d9( i ): " << many1_array_x_d9(i) << endl;
        cout << "many1_array_y_d9( i ): " << many1_array_y_d9(i) << endl;
        cout << "many1_array_iz_d9( i ): " << many1_array_iz_d9(i) << endl << endl;
*/
    }
   
    T4_TEST( agg_many1_agg_struct1_x + ( agg_many1_agg_struct1_y * agg_many1_agg_struct1_iz ) / 20000, 8802.79 );

//    cout << "agg_many1_agg_struct1_x: " << agg_many1_agg_struct1_x << endl << endl;
//    cout << "agg_many1_agg_struct1_y: " << agg_many1_agg_struct1_y << endl << endl;
//    cout << "agg_many1_agg_struct1_iz: " << agg_many1_agg_struct1_iz << endl << endl;

    return 1;
}

