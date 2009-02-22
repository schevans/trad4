
// Please see the comment at the top of calculus/gen/objects/monitor_macros.c
//  to see what's in-scope.

#include <iostream>
#include <fstream> 

#include "monitor_wrapper.c"

using namespace std;

void calculate_monitor( obj_loc_t obj_loc, int id )
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
        outfile << monitor_my_f_x( i ) << ","
            << monitor_my_f_y( i ) << ","
            << monitor_my_df_df( i ) << ","
            << monitor_my_d2f_d2f( i ) << endl;
    }

    outfile.close();

    cout << "Data written to " << filename.str() << endl;

    
/*
    cout << "x,";

    for ( int i=0 ; i < NUM_NODES ; i++ )
    {
        cout << monitor_my_f_x( i ) << ",";
    }

    cout << endl;

    cout << "y,";

    for ( int i=0 ; i < NUM_NODES ; i++ )
    {
        cout << monitor_my_f_y( i ) << ",";
    }

    cout << endl;

    cout << "dy,";

    for ( int i=0 ; i < NUM_NODES ; i++ )
    {
        cout << monitor_my_df_df( i ) << ",";
    }

    cout << endl;

    cout << "d2y,";

    for ( int i=0 ; i < NUM_NODES ; i++ )
    {
        cout << monitor_my_d2f_d2f( i ) << ",";
    }

    cout << endl;
*/
}

