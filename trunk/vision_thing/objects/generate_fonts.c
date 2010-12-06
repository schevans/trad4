// Copyright (c) Steve Evans 2009
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $APP_ROOT/LICENCE

#include "gd.h"

#include <string.h>
#include <iostream>
#include <sstream>
#include <map>

using namespace std;

int main()
{
std::map<int, char*> char_map;

char_map[0] = "0";
char_map[1] = "1";
char_map[2] = "2";
char_map[3] = "3";
char_map[4] = "4";
char_map[5] = "5";
char_map[6] = "6";
char_map[7] = "7";
char_map[8] = "8";
char_map[9] = "9";

    for ( int i=0 ; i < 10 ; i++ )
    {
        gdImagePtr im;

        int black;

        int white;

        int brect[8];

        int x, y;

        char *err;


        char *s = char_map[i];

        double sz = 60.;

        char *f = "/media/disk/Downloads/Harabara.ttf"; /* User supplied font */

         

        /* obtain brect so that we can size the image */

        err = gdImageStringFT(NULL,&brect[0],0,f,sz,0.,0,0,s);

        if (err) {fprintf(stderr,err); return 1;}

         
        /* create an image big enough for the string plus a little whitespace */
        x = brect[2]-brect[6] + 6;
        y = brect[3]-brect[7] + 6;

        im = gdImageCreate(64,64);
         
        /* Background color (first allocated) */
        white = gdImageColorResolve(im, 255, 255, 255);
        black = gdImageColorResolve(im, 0, 0, 0);
         
        /* render the string, offset origin to center string*/
        /* note that we use top-left coordinate for adjustment
        * since gd origin is in top-left with y increasing downwards. */
        x = 3 - brect[6];
        y = 3 - brect[7];
        
        x=((64-brect[2])/2)+2;
        
        err = gdImageStringFT(im,&brect[0],black,f,sz,0.0,x,y,s);
        if (err) {fprintf(stderr,err); return 1;}
        
        std::ostringstream number;
        number << i << ".png";
     
        FILE *pngout = fopen( number.str().c_str(), "wb");

        gdImagePng(im, pngout);

        fclose(pngout);
         
        /* Destroy it */
        gdImageDestroy(im);
    }
}
