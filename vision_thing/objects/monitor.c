// Copyright (c) Steve Evans 2009
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

// Please see the comment at the top of vision_thing/gen/objects/monitor_macros.h
//  to see what's in-scope.

#include <iostream>
#include <map>

#include "gd.h"

#include "monitor_wrapper.c"

void save_weight_matrix( weight_matrix* weight_matrix, string filename );
void create_animation( obj_loc_t obj_loc, int id );

using namespace std;

static int zoom(2);

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

    monitor_converged = 0;

    if ( local_all_correct == 1 )
    {
        if ( monitor_num_cycles_correct >= NUM_IMAGES ) 
        {
            int adjusted_num_runs = monitor_num_runs - ( NUM_IMAGES * ( 1 + input_font_number ));

            cout << "Converged in " << adjusted_num_runs << " runs on font " << input_font_number << endl;
            cout << endl;

            monitor_converged = 1;
            monitor_num_cycles_correct = 0;

            if ( input_font_number == NUM_FONTS-1 )
            {
                create_animation( obj_loc, id );
                exit(0);
            }
        }

        monitor_num_cycles_correct++;
    }

    monitor_num_runs++;

    for ( int i = 0 ; i < NUM_NEURONS ; i++ )
    {
        std::ostringstream filename;
        filename << object_name( ((t4::monitor*)obj_loc[id])->neurons[i]) << "_" << monitor_num_runs << ".png";

        save_weight_matrix( &neurons_weights( i ), filename.str() );
    }

    return 1;
}

void create_animation( obj_loc_t obj_loc, int id )
{
    for ( int neuron_id = 0 ; neuron_id < NUM_NEURONS ; neuron_id++ )
    {
        gdImagePtr imgs[monitor_num_runs];

        imgs[0] = gdImageCreate(NUM_COLS*zoom, NUM_ROWS*zoom);

        (void)gdImageColorAllocate(imgs[0], 127, 127, 127 ); 

        std::ostringstream outfile;
        outfile << "animation_" << neuron_id << ".gif";
        FILE *out = fopen(outfile.str().c_str(), "wb");

        gdImageGifAnimBegin(imgs[0], out, 1, monitor_num_runs);

        gdImageGifAnimAdd(imgs[0], out, 0, 0, 0, 100, 1, NULL);

        for ( int i=1 ; i < monitor_num_runs ; i++ )
        {
            std::ostringstream filename;
            filename << object_name( ((t4::monitor*)obj_loc[id])->neurons[neuron_id]) << "_" << i << ".png";
            FILE *in = fopen(filename.str().c_str(), "rb");
            imgs[i] = gdImageCreateFromPng(in);

            gdImageGifAnimAdd(imgs[i], out, 1, 0, 0, 100, 1, NULL);

            fclose(in);
        }

        gdImageGifAnimEnd(out);
          
        fclose(out);

        for ( int i = 0 ; i < monitor_num_runs ; i++ )
        {
            gdImageDestroy(imgs[i]);
        }
    }
}

void save_weight_matrix( weight_matrix* weight_matrix, string filename )
{
    FILE *pngout = fopen( filename.c_str(), "wb");

    gdImagePtr im = gdImageCreate(NUM_COLS*zoom, NUM_ROWS*zoom);

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
                    int colour = 127 - (int)( this_weight * max_weight_coeff );

                    colour_table[this_weight] = gdImageColorAllocate(im, colour, colour, colour ); 

                   //cout << "Creating new colour for " << this_weight << ": " << colour << "("<< colour_table[this_weight]  <<")" <<endl;
                }
            } 
            else if ( this_weight < 0 )
            {
                if ( ! colour_table[this_weight] )
                {
                    int colour = 127 - (int)( this_weight * -min_weight_coeff );

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

    for ( int row = 0 ; row < NUM_ROWS*zoom ; row++ )
    {
        for ( int col = 0 ; col < NUM_COLS*zoom ; col++ )
        {
            this_weight = (*weight_matrix).row[row/zoom].col[col/zoom]; 
            this_colour = colour_table[this_weight];

            gdImageSetPixel( im, col, row, this_colour );
        }
    }

    gdImagePng(im, pngout);

    fclose(pngout);
    gdImageDestroy(im);

}


