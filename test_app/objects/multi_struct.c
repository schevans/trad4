
// GENERATED BY TRAD4 

// Please see the comment at the top of test_app/gen/objects/multi_struct_macros.h
//  to see what's in-scope.

#include <iostream>

#include "multi_struct_wrapper.c"

using namespace std;

int calculate_multi_struct( obj_loc_t obj_loc, long id )
{

    for ( int row = 0 ; row < NUM_ROWS ; row++ )
    {
        for ( int col = 0 ; col < NUM_ROWS ; col++ )
        {
            cout << multi_struct_images_row_col( 1, row, col );
        }

        cout << endl;
    }

    return 1;
}

