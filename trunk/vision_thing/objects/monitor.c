
// GENERATED BY TRAD4 

// Please see the comment at the top of vision_thing/gen/objects/monitor_macros.h
//  to see what's in-scope.

#include <iostream>
#include <map>

#include "gd.h"

#include "monitor_wrapper.c"

void save_weight_matrix( weight_matrix* weight_matrix, string filename );

using namespace std;

int calculate_monitor( obj_loc_t obj_loc, int id )
{
    if ( ! object_init( id ) )
    {
        monitor_num_runs = 0;
        monitor_num_cycles_correct = 0;
    }

    int local_all_correct = 1;

    for ( int i = 0 ; i < NUM_NEURONS ; i++ )
    {
        if ( neurons_correct(i) == 0 )  
        {
            local_all_correct = 0;
            monitor_num_cycles_correct = 0;
            break;
        }
    }

    if ( local_all_correct == 1 )
    {
        if ( monitor_num_cycles_correct >= NUM_IMAGES ) 
        {
            cout << "Converged in " << monitor_num_runs << " runs." << endl;
            cout << endl;

            exit(0);
        }

        monitor_num_cycles_correct++;
    }

    monitor_num_runs++;

    for ( int i = 0 ; i < NUM_NEURONS ; i++ )
    {
        std::ostringstream filename;
        filename << object_name( ((t4::monitor*)obj_loc[id])->neurons[i]) << "_" << monitor_num_runs << ".png";

        save_weight_matrix( &neurons_weights( i ), filename.str() );

        filename.clear();
    }

    return 1;
}

void save_weight_matrix( weight_matrix* weight_matrix, string filename )
{
    FILE *pngout = fopen( filename.c_str(), "wb");

    gdImagePtr im = gdImageCreate(NUM_COLS, NUM_ROWS);

    double max_weight = 0;
    double min_weight = 0;

    for ( int row = 0 ; row < NUM_ROWS ; row++ )
    {
        for ( int col = 0 ; col < NUM_COLS ; col++ )
        {
            if ( (*weight_matrix).row[row].col[col] > max_weight )
                max_weight = (*weight_matrix).row[row].col[col];

            if ( (*weight_matrix).row[row].col[col] < min_weight )
                min_weight = (*weight_matrix).row[row].col[col];
        }
    }

    double max_weight_coeff = 127/max_weight;
    double min_weight_coeff = 127/min_weight;

    //cout << "max_weight: " << max_weight << ", min_weight: " << min_weight << "max_weight_coeff: " << max_weight_coeff << ", min_weight_coeff: " << min_weight_coeff << endl;

    int grey = gdImageColorAllocate(im, 127, 127, 127 ); 

    std::map<double, int> colour_table;

    double this_weight(0);

    for ( int row = 0 ; row < NUM_ROWS ; row++ )
    {
        for ( int col = 0 ; col < NUM_COLS ; col++ )
        {
            this_weight = (*weight_matrix).row[row].col[col]; 

            if ( this_weight > 0 )
            {
                if ( ! colour_table[this_weight] )
                {

                    int colour = 127 - ( this_weight * max_weight_coeff );

                    colour_table[this_weight] = gdImageColorAllocate(im, colour, colour, colour ); 

                   //cout << "Creating new colour for " << this_weight << ": " << colour << "("<< colour_table[this_weight]  <<")" <<endl;
                }
            } 
            else if ( this_weight < 0 )
            {
                if ( ! colour_table[this_weight] )
                {
                    int colour = 127 - ( this_weight * -min_weight_coeff );

                    colour_table[this_weight] = gdImageColorAllocate(im, colour, colour, colour ); 

                   //cout << "Creating new colour for " << this_weight << ": " << colour << "("<< colour_table[this_weight]  <<")" <<endl;
                }

            }
            else 
            {
                colour_table[this_weight] = grey;
            }

        }
    }

    int this_colour(0);

    for ( int row = 0 ; row < NUM_ROWS ; row++ )
    {
        for ( int col = 0 ; col < NUM_COLS ; col++ )
        {
            this_weight = (*weight_matrix).row[row].col[col]; 
            this_colour = colour_table[this_weight];

            gdImageSetPixel( im, col, row, this_colour );
        }
    }

    gdImagePng(im, pngout);

    fclose(pngout);
    gdImageDestroy(im);

}


