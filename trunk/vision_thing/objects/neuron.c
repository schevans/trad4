// Copyright (c) Steve Evans 2009
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

// Please see the comment at the top of vision_thing/gen/objects/neuron_macros.h
//  to see what's in-scope.

#include <iostream>
#include <iomanip>
#include <map>

#include "gd.h"

#include "neuron_wrapper.c"

void print_weights( obj_loc_t obj_loc, int id );
void save_weight_matrix( weight_matrix* weight_matrix, string filename );

using namespace std;

static int zoom(2);

int calculate_neuron( obj_loc_t obj_loc, int id )
{
    int local_run_number = monitor_num_runs;

    if ( ! object_init( id ) )
    {
        for ( int row = 0 ; row < NUM_ROWS ; row++ )
        {
            for ( int col = 0 ; col < NUM_ROWS ; col++ )
            {
                neuron_weights_row_col( row, col ) = 0.0;
            }
        }

        local_run_number = 0;
    }

    if ( object_log_level(id) >= 2 )
    {
        print_weights( obj_loc, id );
    }

    double local_agg(0);

    for ( int row = 0 ; row < NUM_ROWS ; row++ )
    {
        for ( int col = 0 ; col < NUM_ROWS ; col++ )
        {
            local_agg = local_agg + ( input_fonts_images_row_col( input_font_number, input_image_number, row, col ) * neuron_weights_row_col( row, col ));
        }
    }

    int local_correct(0);

    if ( local_agg >= 0.0 )
    {
        local_correct = 1;
    }
    else
    {
        local_correct = 0;
    }

    if ( ( local_correct && ( neuron_image == input_image_number )) || ( ! local_correct && ( neuron_image != input_image_number )))
    {
        DEBUG( "Correct: " << object_name(id) << " says " << ( local_correct ? "yes" : "no" ) << ", it's looking for " << neuron_image << " and being shown " << input_image_number << "." );

        neuron_output = CORRECT;
    }
    else
    {
        if ( local_correct == 1 && neuron_image != input_image_number )
        {
            neuron_output = FALSE_POSITIVE;

            DEBUG( "Incorrect: " << object_name(id) << " says yes but it's looking for " << neuron_image << " but being shown " << input_image_number << ". Reducing active inputs by " << ( 1.0 / NUM_IMAGES ) << "." );
            for ( int row = 0 ; row < NUM_ROWS ; row++ )
            {
                for ( int col = 0 ; col < NUM_ROWS ; col++ )
                {
                    if ( input_fonts_images_row_col( input_font_number, input_image_number, row, col ) == 1 ) 
                    {
                        neuron_weights_row_col( row, col ) = neuron_weights_row_col( row, col ) - ( 1.0 / NUM_IMAGES );
                    
                        if ( fabs( neuron_weights_row_col( row, col )) < 1.0e-10 )
                        {
                            neuron_weights_row_col( row, col ) = 0.0;
                        }
                    }
                }
            }
        }

        if ( local_correct == 0 && neuron_image == input_image_number )
        { 
            neuron_output = FALSE_NEGATIVE;

            DEBUG( "Incorrect: " << object_name(id) << " says no but it's looking for " << neuron_image << " and being shown " << input_image_number << ". Increasing active inputs by " << 1.0 << "." );
            for ( int row = 0 ; row < NUM_ROWS ; row++ )
            {
                for ( int col = 0 ; col < NUM_ROWS ; col++ )
                {
                    if ( input_fonts_images_row_col( input_font_number, input_image_number, row, col ) == 1 ) 
                    {
                        neuron_weights_row_col( row, col ) = neuron_weights_row_col( row, col ) + 1.0;
                        
                        if ( fabs( neuron_weights_row_col( row, col ) ) < 1.0e-10 )
                        {
                            neuron_weights_row_col( row, col ) = 0.0;
                        }
                    }
                }
            }
        }
    }

    //print_weights( obj_loc, id );

    std::ostringstream filename;
    filename << object_name( id ) << "_" << local_run_number<< ".png";
    save_weight_matrix( &neuron_weights, filename.str() );

    return 1;
}

void print_weights( obj_loc_t obj_loc, int id )
{
    for ( int row = 0 ; row < NUM_ROWS ; row++ )
    {
        for ( int col = 0 ; col < NUM_ROWS ; col++ )
        {
            printf("%5.1f", neuron_weights_row_col( row, col ));
        }

        cout << endl;
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


