
// GENERATED BY TRAD4 

// Please see the comment at the top of test_app/gen/objects/addition_macros.h
//  to see what's in-scope.

#include <iostream>

#include "addition_wrapper.c"

using namespace std;

int calculate_addition( obj_loc_t obj_loc, int id )
{
    addition_output = numeric1_output + numeric2_output;

    T4_TEST( addition_output, 10.055 );

    return 1;
}

