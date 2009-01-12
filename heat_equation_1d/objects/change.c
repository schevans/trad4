
// Please see the comment at the top of heat_equation_1d/gen/objects/change_macros.c
//  to see what's in-scope.

#include <iostream>

#include "change_wrapper.c"

using namespace std;

void calculate_change( obj_loc_t obj_loc, int id )
{
    switch ( this_element_element_type )
    {
        case MIDDLE:
            change_change = K * ( up_element_y - 2*this_element_y + down_element_y );
            break;

        case START:
            change_change = K * ( up_element_y - 2*this_element_y + ALPHA );
            break;

        case END:
            change_change = K * ( BETA - 2*this_element_y + down_element_y );
            break;

        default:
            cerr << "Default case reached in switch. Exiting" << endl;
            exit(0);
    }
}

