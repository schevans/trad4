// Copyright (c) Steve Evans 2009
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $APP_ROOT/LICENCE

// Please see the comment at the top of vision_thing/gen/objects/monitor_macros.h
//  to see what's in-scope.

#include <iostream>
#include <fstream>
#include <map>

#include "gd.h"
#include "gdfontg.h"

#include "monitor_wrapper.c"

#include "common.c"

void create_animation( obj_loc_t obj_loc, int id );
void collect_data( obj_loc_t obj_loc, int id );
int all_neurons_correct( obj_loc_t obj_loc, int id );

using namespace std;

static int zoom(2);

static map<int, string> font_map;

int calculate_monitor( obj_loc_t obj_loc, int id )
{
    if ( ! object_init( id ) )
    {
        init_font_map( font_map );
        monitor_image_number = 0;
        monitor_font_number = 0;
        monitor_run_number = 0;
        monitor_num_correct_neurons = 0;
        monitor_font_results_start( 0 ) = 0;
        monitor_converged = 0;
    }
    else
    {

    collect_data( obj_loc, id );
    
    int local_all_correct = all_neurons_correct( obj_loc, id );

    if ( local_all_correct )
    {
        monitor_num_correct_neurons++;
    }
    else
    {
        monitor_num_correct_neurons = 0;
    }

    if ( monitor_num_correct_neurons >= NUM_IMAGES )
    {
        int adjusted_num_runs = monitor_run_number;

        monitor_font_results_end(monitor_font_number) = adjusted_num_runs;

        cout << "Font " << font_map[monitor_font_number];

        int local_num_converged = monitor_font_results_end(monitor_font_number) - monitor_font_results_start(monitor_font_number) - NUM_IMAGES+1;

        if ( local_num_converged == 0 )
        {
            cout << " has converged." << endl;
        }
        else
        {
            cout << " converged in " << local_num_converged << " cycles." << endl;
        }

        if ( monitor_font_number == NUM_FONTS-1 )
        {
            monitor_font_number = 0;
            monitor_num_correct_neurons = 0;

            cout << endl;
        }
        else
        {
            monitor_font_number++;
            monitor_num_correct_neurons = 0;
        }

        monitor_font_results_start(monitor_font_number) = monitor_run_number+1;
    }

    if ( monitor_image_number < NUM_IMAGES-1 )
    {
        monitor_image_number++;
    }
    else
    {
        monitor_image_number = 0;
    }

    monitor_run_number++;

    if ( monitor_run_number > MAX_NUM_RUNS )
    {
        cout << "Creating animation.." << endl;

        create_animation( obj_loc, id );

        cout << "Creating output file.." << endl;

        ofstream outfile("vt_out.csv");

        outfile << "run,image,font";

        for ( int neuron_id = 0 ; neuron_id < NUM_NEURONS ; neuron_id++ )
        {
            outfile << "," << object_name( monitor_neurons[neuron_id] );
        }

        outfile << endl;

        for ( int run_num = 0 ; run_num < MAX_NUM_RUNS ; run_num++ )
        {
            outfile << run_num << "," << monitor_run_results_image(run_num) << "," << monitor_run_results_font(run_num);

            for ( int neuron_id = 0 ; neuron_id < NUM_NEURONS ; neuron_id++ )
            {
                outfile << "," << monitor_run_results_neuron_output( run_num, neuron_id );
            }

            outfile << endl;
        }

        outfile.close();

        cout << "Done." << endl;

        exit(0);
    }

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

    gdImageGifAnimBegin(master_img, out, 1, monitor_run_number);

    gdImageGifAnimAdd(master_img, out, 0, 0, 0, 100, 1, NULL);

    int num_correct(0);
    int num_incorrect(0);

    gdImagePtr frame_imgs[MAX_NUM_RUNS];

    int num_font_correct(0);
    int num_font_incorrect(0);
    int font_num(0);

    for ( int run_num = 0 ; run_num < MAX_NUM_RUNS ; run_num++ )
    {
        if ( font_num != monitor_run_results_font( run_num ) )
        {
            num_font_correct = 0;
            num_font_incorrect = 0;
            font_num = monitor_run_results_font( run_num );
        }

        frame_imgs[run_num] = gdImageCreate(master_img_width, master_img_height);

        gdImagePtr imgs[NUM_IMAGES];

        for ( int neuron_id = 0 ; neuron_id < NUM_NEURONS ; neuron_id++ )
        {
            std::ostringstream filename;
            filename << object_name( ((t4::monitor*)obj_loc[id])->neurons[neuron_id]) << "_" << run_num << ".png";
            FILE *in = fopen(filename.str().c_str(), "rb");

            imgs[neuron_id] = gdImageCreateFromPng(in);

            int red = gdImageColorAllocate(imgs[neuron_id], 255, 0, 0);  
            int green = gdImageColorAllocate(imgs[neuron_id], 0, 255, 0);  
            int blue = gdImageColorAllocate(imgs[neuron_id], 0, 0, 255);  

            int this_colour;

            if ( monitor_run_results_neuron_output( run_num, neuron_id ) == CORRECT )
            {
                this_colour = green;
                num_font_correct++;
                num_correct++;
            }
            else if ( monitor_run_results_neuron_output( run_num, neuron_id ) == FALSE_NEGATIVE )
            {
                this_colour = red;
                num_font_incorrect++;
                num_incorrect++;
            }
            else if ( monitor_run_results_neuron_output( run_num, neuron_id ) == FALSE_POSITIVE )
            {
                this_colour = blue;
                num_font_incorrect++;
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

        if (err) { cerr << err << endl; exit(1); }

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
        if (err) { cerr << err << endl; exit(1); }

        // 2nd row
        std::ostringstream second_row_text;
        second_row_text << num_font_correct << "," << num_font_incorrect << "    " << num_correct << "," << num_incorrect;

        string tmp_str2 = second_row_text.str();

        char *s2 = (char*)tmp_str2.c_str();

        err = gdImageStringFT(NULL,&brect[0],0,f,sz,0.,0,0,s2);

        if (err) { cerr << err << endl; exit(1); }

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
        if (err) { cerr << err << endl; exit(1); }

        gdImageCopy(frame_imgs[run_num], text_pane, png_frame_width, png_frame_height*2, 0, 0, png_frame_width*4, png_frame_height );

        int delay = 100;

        if ( run_num == 0 ) 
        {
            gdImageGifAnimAdd(frame_imgs[run_num], out, 1, 0, 0, delay, 1, NULL);
        }
        else 
        {
            gdImageGifAnimAdd(frame_imgs[run_num], out, 1, 0, 0, delay, 1, frame_imgs[run_num-1]);
        }

        gdImageDestroy(text_pane);
        gdImageDestroy(input_image);

        for ( int i = 0 ; i < NUM_IMAGES ; i++ )
        {
            gdImageDestroy(imgs[i]);
        }
    }

    gdImageGifAnimEnd(out);

    for ( int run_num = 0 ; run_num < MAX_NUM_RUNS ; run_num++ )
    {
        gdImageDestroy(frame_imgs[run_num]);
    }

    fclose(out);
}

void collect_data( obj_loc_t obj_loc, int id )
{
    for ( int i = 0 ; i < NUM_NEURONS ; i++ )
    {
        monitor_run_results_neuron_output( monitor_run_number, i ) = neurons_output(i);
    }

    monitor_run_results_image( monitor_run_number ) = monitor_image_number;
    monitor_run_results_font( monitor_run_number ) = monitor_font_number;
}

int all_neurons_correct( obj_loc_t obj_loc, int id )
{
    int retval=1;

    for ( int i = 0 ; ( i < NUM_NEURONS && retval ) ; i++ )
    {
        if ( neurons_output(i) != CORRECT )  
        {
            retval = 0;
        }
    }

    return retval;
}
