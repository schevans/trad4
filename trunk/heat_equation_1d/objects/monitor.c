// Copyright (c) Steve Evans 2009
// steve@topaz.myzen.co.uk
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE

// Please see the comment at the top of heat_equation_1d/gen/objects/monitor_macros.c
//  to see what's in-scope.

#include <iostream>
#include <math.h>
#include <sys/time.h>

#include "monitor_wrapper.c"

using namespace std;

void print_data( obj_loc_t obj_loc, int id );
double get_timestamp();

int calculate_monitor( obj_loc_t obj_loc, int id )
{

    if ( monitor_counter == 0 && ! monitor_print_each_cycle )
    {
        print_data( obj_loc, id );
        cout << endl;

        monitor_start_time = get_timestamp();
    }

    if ( monitor_print_each_cycle )
    {
        print_data( obj_loc, id );
    }

    int converged = 1;
    int diverged = 0;

    for ( int i=0 ; i < NUM_NODES ; i++ )
    {
        if ( fabs( changes_change(i) ) > monitor_diverged_limit )
        {
            diverged = 1;
            break;
        }

        if ( converged && fabs( changes_change(i) ) > monitor_converged_limit )
        {
            converged = 0; 
        }
    }

    if ( converged )
    {

        print_data( obj_loc, id );

        double local_end_time = get_timestamp();

        cout << "Converged in " << monitor_counter << " steps which took " << local_end_time - monitor_start_time << " seconds with k = " << data_server_k << endl;

        exit(0);
    }

    if ( diverged )
    {
        print_data( obj_loc, id );

        double local_end_time = get_timestamp();

        cout << "Diverged in " << monitor_counter << " steps which took " << local_end_time - monitor_start_time << " seconds with k = "<< data_server_k  << endl;

        exit(0);
    }

    monitor_counter = monitor_counter + 1;

    return 1;
}

void print_data( obj_loc_t obj_loc, int id )
{
    cout << "x";

    for ( int i=0 ; i < NUM_NODES ; i++ )
    {
        cout << "," << elements_x(i);
    }

    cout << endl << "y";

    for ( int i=0 ; i < NUM_NODES ; i++ )
    {
        cout << "," << elements_y(i);
    }

    cout << endl << "change";

    for ( int i=0 ; i < NUM_NODES ; i++ )
    {
        cout << "," << changes_change(i);
    }

    cout << endl;
}

double get_timestamp()
{
    timeval tim;
    gettimeofday(&tim, NULL);
    return tim.tv_sec + ( tim.tv_usec / 1000000.0 );
}

