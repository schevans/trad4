
#include <iostream>
#include <math.h>

#include "option_feed_wrapper.c"

using namespace std;

void* calculate_option_feed( int id )
{
    DEBUG( "calculate_option_feed( " << id << ")" )

    option_feed_RrT = sqrt( option_feed_T );
}

