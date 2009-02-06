
// Please see the comment at the top of test_suite/gen/objects/addition_macros.c
//  to see what's in-scope.

#include <iostream>

#include "addition_wrapper.c"

using namespace std;

void calculate_addition( obj_loc_t obj_loc, int id )
{
    if ( numeric1_output == 0 ) {
        
        addition_output = 1;
    }
    else {

        addition_output = numeric1_output + numeric2_output;

    }
}

