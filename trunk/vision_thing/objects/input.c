// Copyright (c) Steve Evans 2009
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

// Please see the comment at the top of vision_thing/gen/objects/input_macros.h
//  to see what's in-scope.

#include <iostream>
#include <map>

#include "gd.h"


#include "input_wrapper.c"

#include "common.c"

void load_image( image* image, string filename );

using namespace std;

static map<int, string> font_map;

int calculate_input( obj_loc_t obj_loc, int id )
{
    static char* vs_data_dir = getenv("VS_DATA_DIR");

    if ( ! vs_data_dir )
    {
        cout << "VS_DATA_DIR unset" << endl;
        exit(0);
    }

    if ( ! object_init( id ) )
    {
        init_font_map( font_map );
        
        input_image_number = 0;
        input_font_number = 0;

        for ( int font=0 ; font < NUM_FONTS ; font++ )
        {

            for ( int image = 0 ; image < NUM_IMAGES ; image++ )
            {
                std::ostringstream filename;
                filename << vs_data_dir << "/" << font_map[font] << "/" << image << ".png";

                load_image( &input_fonts_images( font, image), filename.str() );
            }
        }
    }
    else
    {
        if ( input_image_number < NUM_IMAGES-1 )
        {
            input_image_number = input_image_number + 1;
        }
        else
        {
            input_image_number = 0;
        }
    }

    if ( monitor_converged )
    {
        if ( input_font_number < NUM_FONTS-1 )
        {
            input_font_number = input_font_number + 1;
        }
        else
        {
            input_font_number = 0;
        }
    }

    if ( object_log_level(id) >= 2 )
    {
        for ( int row = 0 ; row < NUM_ROWS ; row++ )
        {
            for ( int col = 0 ; col < NUM_ROWS ; col++ )
            {
                cout << input_fonts_images_row_col( 0, input_image_number, row, col );
            }

            cout << endl;
        }
    }

    return 1;
}

void load_image( image* image, string filename )
{
    FILE *pngin = fopen( filename.c_str(), "r");

    gdImagePtr im = gdImageCreateFromPng(pngin);

    for ( int row = 0 ; row < NUM_ROWS ; row++ )
    {
        for ( int col = 0 ; col < NUM_ROWS ; col++ )
        {
            if ( gdImageGetPixel( im, col, row ) > 0 ) 
            {
               (*image).row[row].col[col] = 1;
            }
            else
            {
               (*image).row[row].col[col] = 0;
            }
        }
    }

    fclose(pngin);

    gdImageDestroy(im);
}

