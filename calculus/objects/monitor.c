// Copyright (c) Steve Evans 2009
// steve@topaz.myzen.co.uk
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE

// Please see the comment at the top of calculus/gen/objects/monitor_macros.c
//  to see what's in-scope.

#include <iostream>
#include <fstream> 

#include "monitor_wrapper.c"

using namespace std;

int calculate_monitor( obj_loc_t obj_loc, int id )
{

    std::ostringstream filename;
    filename << getenv("APP_ROOT") << "/" << getenv("APP") << "_" << NUM_NODES << ".csv";

    ofstream outfile( filename.str().c_str() );

    if ( !outfile ) {

        cout << "monitor can't open " << filename << " for writing." << endl;
        exit(1);
    }

    outfile << "x,y,df,d2f" << endl;

    for ( int i=0 ; i < NUM_NODES ; i++ )
    {
        outfile << f_x( i ) << ","
            << f_y( i ) << ","
            << df_df( i ) << ","
            << d2f_d2f( i ) << endl;
    }

    outfile.close();

    cout << "Data written to " << filename.str() << endl;
    
    return 1;
}

