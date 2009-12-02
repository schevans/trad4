
// GENERATED BY TRAD4 

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
        srand( neuron_random_seed );

        double local_weight_coeff = 0.02;

        for ( int row = 0 ; row < NUM_ROWS ; row++ )
        {
            for ( int col = 0 ; col < NUM_ROWS ; col++ )
            {
                neuron_my_weight_matrix_rows_weight( row, col ) = ( local_weight_coeff * rand() / (RAND_MAX + 1.0) );
            }

        }

    }

    //print_weights( obj_loc, id );

    double local_agg(0);

    for ( int row = 0 ; row < NUM_ROWS ; row++ )
    {
        for ( int col = 0 ; col < NUM_ROWS ; col++ )
        {
            local_agg = local_agg + ( input_images_row_col( input_image_number, row, col ) * neuron_my_weight_matrix_rows_weight( row, col ));
        }
    }

    if ( local_agg > neuron_threshold )
    {
        neuron_output = 1;
    }
    else
    {
        neuron_output = 0;
    }

    cout << "local_agg: " << local_agg << ", neuron_threshold: " << neuron_threshold << endl;

    if ( ( neuron_output && ( neuron_image == input_image_number )) || ( ! neuron_output && ( neuron_image != input_image_number )))
    {
        cout << "Correct: neuron says " << ( neuron_output ? "yes" : "no" ) << ", it's looking for " << neuron_image << " and being shown " << input_image_number << "." << endl;
    }
    else
    {
        cout << "Incorrect" << endl;

        if ( neuron_output == 1 && neuron_image != input_image_number )
        {
            cout << "Incorrect: neuron says yes but it's looking for " << neuron_image << " but being shown " << input_image_number << ". Reducing active inputs by " << ( neuron_bump / NUM_IMAGES ) << "." << endl;
            for ( int row = 0 ; row < NUM_ROWS ; row++ )
            {
                for ( int col = 0 ; col < NUM_ROWS ; col++ )
                {
                    if ( input_images_row_col( input_image_number, row, col ) == 1 ) 
                    {
                        neuron_my_weight_matrix_rows_weight( row, col ) = neuron_my_weight_matrix_rows_weight( row, col ) - ( neuron_bump / NUM_IMAGES );

                    //cout << "Decreasing (" << row << ", " << col << ") by " << ( neuron_bump / NUM_IMAGES ) << endl; 
                    }
                }
            }
        }

        if ( neuron_output == 0 && neuron_image == input_image_number )
        { 
            cout << "Incorrect: neuron says no but it's looking for " << neuron_image << " and being shown " << input_image_number << ". Reducing active inputs by " << ( neuron_bump / NUM_IMAGES ) << "." << endl;
            for ( int row = 0 ; row < NUM_ROWS ; row++ )
            {
                for ( int col = 0 ; col < NUM_ROWS ; col++ )
                {
                    if ( input_images_row_col( input_image_number, row, col ) == 1 )
                    {
                        neuron_my_weight_matrix_rows_weight( row, col ) = neuron_my_weight_matrix_rows_weight( row, col ) + neuron_bump;
                        //cout << "Increasing (" << row << ", " << col << ") by " << neuron_bump << endl; 
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
            cout << setprecision(4) << neuron_my_weight_matrix_rows_weight( row, col ) << ",";
        }

        cout << endl;
    }
}
