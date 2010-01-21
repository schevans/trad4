// Copyright (c) Steve Evans 2009
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

// Please see the comment at the top of vision_thing/gen/objects/monitor_macros.h
//  to see what's in-scope.

#include <iostream>
#include <map>

#include "gd.h"
#include "gdfontg.h"

#include "monitor_wrapper.c"

#include "common.c"

void save_weight_matrix( weight_matrix* weight_matrix, string filename );
void create_animation( obj_loc_t obj_loc, int id );

using namespace std;

static int zoom(2);

static map<int, string> font_map;

int calculate_monitor( obj_loc_t obj_loc, int id )
{
    if ( ! object_init( id ) )
    {
        init_font_map( font_map );
        monitor_num_runs = 0;
        monitor_num_cycles_correct = 0;
        monitor_font_results_start( 0 ) = 0;
    }

    int local_all_correct = 1;

    for ( int i = 0 ; i < NUM_NEURONS ; i++ )
    {
        if ( neurons_correct(i) == 0 )  
        {
            local_all_correct = 0;
            monitor_num_cycles_correct = 0;
        

        }

        monitor_run_results_row( monitor_num_runs, i ) = neurons_correct(i);
    }

    monitor_run_results_image( monitor_num_runs ) = input_image_number;

    monitor_converged = 0;

    if ( local_all_correct == 1 )
    {
        if ( monitor_num_cycles_correct >= NUM_IMAGES ) 
        {
            int adjusted_num_runs = monitor_num_runs - ( NUM_IMAGES * ( 1 + input_font_number ));

            cout << "Converged in " << adjusted_num_runs << " runs on font " << input_font_number << endl;
            cout << endl;

            monitor_font_results_end(input_font_number) = adjusted_num_runs;
            
            monitor_converged = 1;
            monitor_num_cycles_correct = 0;

            if ( input_font_number == NUM_FONTS-1 )
            {
                for ( int i=0 ; i < NUM_FONTS ; i++ )
                {
                    cout << "Font " << i << " start: " << monitor_font_results_start(i) << ", end: " << monitor_font_results_end(i) << ", total: " << monitor_font_results_end(i) - monitor_font_results_start(i) << endl;

                    for ( int j=monitor_font_results_start(i)  ; j < monitor_font_results_end(i) ; j++ )
                    {
                        for ( int num_neurons=0 ; num_neurons < NUM_NEURONS ; num_neurons++ )
                        {
                            cout << monitor_run_results_row( j, num_neurons );
                        }
                        cout << endl; 
                    }
                }

                create_animation( obj_loc, id );

                exit(0);
            }
            else
            {
                monitor_font_results_start(input_font_number+1) = monitor_num_runs+1;
            }
        }

        monitor_num_cycles_correct++;
    }

    monitor_num_runs++;

    if ( monitor_num_runs > MAX_NUM_RUNS )
    {
        cerr << "Error: Num runs exceeded MAX_NUM_RUNS=" << MAX_NUM_RUNS << ". Please increase, precompile, compile and re-start." << endl;
    }

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
    int num_row_png = 3;
    int num_col_png = 5;

    int png_frame_height = NUM_COLS * zoom;
    int png_frame_width = NUM_ROWS * zoom;
    
    int master_img_height = png_frame_height * num_row_png;
    int master_img_width = png_frame_width * num_col_png;

    gdImagePtr master_img = gdImageCreate(master_img_width, master_img_height);

    (void)gdImageColorAllocate(master_img, 255, 255, 255 ); 

    std::ostringstream outfile;
    outfile << "animation" << ".gif";
    FILE *out = fopen(outfile.str().c_str(), "wb");

    gdImageGifAnimBegin(master_img, out, 1, monitor_num_runs);

    gdImageGifAnimAdd(master_img, out, 0, 0, 0, 100, 1, NULL);

    gdImagePtr frame_imgs[MAX_NUM_RUNS];

    for ( int font_num=0 ; font_num < NUM_FONTS ; font_num++ )
    {
        int num_correct(0);
        int num_incorrect(0);

        for ( int run_num = monitor_font_results_start(font_num) ; run_num < monitor_font_results_end(font_num) ; run_num++ )
        {
            frame_imgs[run_num] = gdImageCreate(master_img_width, master_img_height);

            gdImagePtr imgs[NUM_IMAGES];

            for ( int neuron_id = 0 ; neuron_id < NUM_NEURONS ; neuron_id++ )
            {
                std::ostringstream filename;
                filename << object_name( ((t4::monitor*)obj_loc[id])->neurons[neuron_id]) << "_" << run_num+1 << ".png";
                FILE *in = fopen(filename.str().c_str(), "rb");

                imgs[neuron_id] = gdImageCreateFromPng(in);

                int red = gdImageColorAllocate(imgs[neuron_id], 255, 0, 0);  
                int green = gdImageColorAllocate(imgs[neuron_id], 0, 255, 0);  

                int this_colour;

                if ( monitor_run_results_row( run_num, neuron_id ) == 1 )
                {
                    this_colour = green;
                    num_correct++;
                }
                else
                {
                    this_colour = red;
                    num_incorrect++;
                }

                // Left side
                gdImageLine(imgs[neuron_id], 0, 0, 0, png_frame_height, this_colour);
                gdImageLine(imgs[neuron_id], 1, 0, 1, png_frame_height, this_colour);

                // Top
                gdImageLine(imgs[neuron_id], 0, 0, png_frame_width, 0, this_colour);
                gdImageLine(imgs[neuron_id], 0, 1, png_frame_width, 1, this_colour);

                // Bottom
                gdImageLine(imgs[neuron_id], 0, png_frame_width-1, png_frame_width-1, png_frame_height-1, this_colour);
                gdImageLine(imgs[neuron_id], 0, png_frame_width-2, png_frame_width-2, png_frame_height-2, this_colour);

                // Right side
                gdImageLine(imgs[neuron_id], png_frame_width-1, png_frame_height-1, png_frame_width-1, 0, this_colour);
                gdImageLine(imgs[neuron_id], png_frame_width-2, png_frame_height-2, png_frame_width-2, 0, this_colour);

                int dstX = neuron_id * png_frame_width;
                if ( neuron_id >= 5 )
                    dstX = ( neuron_id - 5 ) * png_frame_width;

                int dstY = 0;
                if ( neuron_id >= 5 )
                    dstY = png_frame_height;

                gdImageCopy(frame_imgs[run_num], imgs[neuron_id], dstX, dstY, 0, 0, png_frame_width, png_frame_height );

                fclose(in);
            }

            // Load and add the image being shown
            static char* vs_data_dir = getenv("VS_DATA_DIR");

            std::ostringstream input_filename;
            input_filename << vs_data_dir << "/" << font_map[font_num] << "/" << monitor_run_results_image( run_num ) << ".png";

            FILE *input_in = fopen( input_filename.str().c_str(), "r");

            gdImagePtr input_image = gdImageCreateFromPng(input_in);

            gdImageCopyResized(frame_imgs[run_num], input_image, 0, (png_frame_height*2), 0, 0, png_frame_width, png_frame_height, NUM_COLS, NUM_ROWS );

            fclose(input_in);

            // Add the text pane
            gdImagePtr text_pane = gdImageCreate( png_frame_width*4, png_frame_height);

            // Set text pane background colour (white)
            (void)gdImageColorAllocate(text_pane, 255, 255, 255 ); 

            // Text
            // 1st row
            int x, y;

            std::ostringstream font_filename;
            font_filename << vs_data_dir << "/" << font_map[font_num] << "/" << font_map[font_num] << ".ttf";

            string tmp_str(font_filename.str());

            char *f = (char*)(tmp_str.c_str());
            double sz = 40.;
            int brect[8];
            char *s = (char*)font_map[font_num].c_str();

            char* err = gdImageStringFT(NULL,&brect[0],0,f,sz,0.,0,0,s);

            if (err) {fprintf(stderr,err); exit(1);}

            /* create an image big enough for the string plus a little whitespace */
            x = brect[2]-brect[6] + 12;
            y = brect[3]-brect[7] + 12;

            int n_black = gdImageColorResolve(text_pane, 0, 0, 0);

            /* render the string, offset origin to center string*/
            /* note that we use top-left coordinate for adjustment
            * since gd origin is in top-left with y increasing downwards. */
            x = 3 - brect[6];
            y = 3 - brect[7];

            err = gdImageStringFT(text_pane,&brect[0],n_black,f,sz,0.0,x,y,s);
            if (err) {fprintf(stderr,err); exit(1);}

            // 2nd row
            std::ostringstream second_row_text;
            second_row_text << num_correct << "," << num_incorrect;

            string tmp_str2 = second_row_text.str();

            char *s2 = (char*)tmp_str2.c_str();

            err = gdImageStringFT(NULL,&brect[0],0,f,sz,0.,0,0,s2);

            if (err) {fprintf(stderr,err); exit(1);}

            /* create an image big enough for the string plus a little whitespace */
            x = brect[2]-brect[6] + 6;
            y = brect[3]-brect[7] + 6;

            /* render the string, offset origin to center string*/
            /* note that we use top-left coordinate for adjustment
            * since gd origin is in top-left with y increasing downwards. */
            x = 3 - brect[6];
            y = 3 - brect[7];

            y = y + 64;

            err = gdImageStringFT(text_pane,&brect[0],n_black,f,sz,0.0,x,y,s2);
            if (err) {fprintf(stderr,err); exit(1);}

            gdImageCopy(frame_imgs[run_num], text_pane, png_frame_width, png_frame_height*2, 0, 0, png_frame_width*4, png_frame_height );

            gdImageGifAnimAdd(frame_imgs[run_num], out, 1, 0, 0, 100, 1, NULL);

            gdImageDestroy(text_pane);
            gdImageDestroy(input_image);

            for ( int i = 0 ; i < NUM_IMAGES ; i++ )
            {
                gdImageDestroy(imgs[i]);
            }
        }
    }

    gdImageGifAnimEnd(out);
      
    fclose(out);
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


