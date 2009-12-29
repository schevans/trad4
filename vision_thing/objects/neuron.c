// Copyright (c) Steve Evans 2009
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

// Please see the comment at the top of vision_thing/gen/objects/neuron_macros.h
//  to see what's in-scope.

#include <iostream>
#include <iomanip>

#include "neuron_wrapper.c"

using namespace std;

void print_weights( obj_loc_t obj_loc, int id );

int calculate_neuron( obj_loc_t obj_loc, int id )
{
    if ( ! object_init( id ) )
    {
        for ( int row = 0 ; row < NUM_ROWS ; row++ )
        {
            for ( int col = 0 ; col < NUM_ROWS ; col++ )
            {
                neuron_weights_row_col( row, col ) = 0.0;
            }
        }
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

    if ( local_agg > 0.0 )
    {
        neuron_output = 1;
    }
    else
    {
        neuron_output = 0;
    }

    if ( ( neuron_output && ( neuron_image == input_image_number )) || ( ! neuron_output && ( neuron_image != input_image_number )))
    {
        DEBUG( "Correct: " << object_name(id) << " says " << ( neuron_output ? "yes" : "no" ) << ", it's looking for " << neuron_image << " and being shown " << input_image_number << "." );

        neuron_correct = 1;
    }
    else
    {
        neuron_correct = 0;

        if ( neuron_output == 1 && neuron_image != input_image_number )
        {
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

        if ( neuron_output == 0 && neuron_image == input_image_number )
        { 
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
