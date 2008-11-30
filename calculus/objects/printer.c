
#include <iostream>
#include "trad4.h"

#include "constants.h"
#include "d2f.h"
#include "d2f_macros.h"
#include "df.h"
#include "df_macros.h"
#include "enums.h"
#include "f.h"
#include "f_macros.h"
#include "structures.h"


using namespace std;

extern "C" void printer( obj_loc_t obj_loc, tier_manager_t tier_manager )
{
    cout << "Printing.." << endl;

    int id;

cout << "TM: " << tier_manager[1][0] << endl;

    for ( int i=1 ; i <= tier_manager[1][0] ; i++ )
    {
        if ( obj_loc[tier_manager[1][i]] )
        {
            id = tier_manager[1][i];
            cout << f_x << ",";
        }
    }

    cout << endl;

    for ( int i=1 ; i <= tier_manager[1][0] ; i++ )
    {
        if ( obj_loc[tier_manager[1][i]] )
        {
            id = tier_manager[1][i];
            cout << f_y << ",";
        }
    }

    cout << endl;

    for ( int i=1 ; i <= tier_manager[2][0] ; i++ )
    {
        if ( obj_loc[tier_manager[2][i]] )
        {
            id = tier_manager[2][i];
            cout << df_df << ",";
        }
    }

    cout << endl;

    for ( int i=1 ; i <= tier_manager[3][0] ; i++ )
    {
        if ( obj_loc[tier_manager[3][i]] )
        {
            id = tier_manager[3][i];
            cout << d2f_d2f << ",";
        }
    }

    cout << endl;

}
