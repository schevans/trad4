
#include <iostream>
#include "trad4.h"

#include "element_macros.h"
#include "element.h"
#include "change_macros.h"
#include "change.h"

using namespace std;

extern "C" void printer( obj_loc_t obj_loc, tier_manager_t tier_manager )
{
    int id;
   
    cout << "REZ,";
 
    for ( int i=1 ; i <= tier_manager[1][0] ; i++ )
    {
        if ( obj_loc[tier_manager[1][i]] )
        {
            id = tier_manager[1][i];
            cout << element_value << ",";
        }
    }

    sleep(1);
}
