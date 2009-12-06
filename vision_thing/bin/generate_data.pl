#!/usr/bin/perl

use warnings;
use strict;

my $outfile = "/home/steve/src/vision_thing/data/16bit_numbers/gen.sql";
open OUTFILE, ">$outfile" or die "Can't open $outfile.\n";

my $row;

my $NUM_ROWS = 16;
my $NUM_COLUMNS = 16;

my $input_id = 9999;
my $monitor_id = 10000;

my @image;

print OUTFILE "delete from object;\n";
print OUTFILE "delete from input;\n";
print OUTFILE "delete from neuron;\n";
print OUTFILE "delete from input_images;\n";
print OUTFILE "delete from input_images_row;\n";
print OUTFILE "delete from input_images_row_col;\n";

print OUTFILE "insert into object values ( $input_id, 1, 1, \"input\", 0, 1 );\n";
print OUTFILE "insert into input values ( $input_id, $monitor_id );\n";

my $image;
my $neuron_id;

my @images = ( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 );

for $image ( @images ) {

    my $row_counter=0;

    my $infile = "/home/steve/src/vision_thing/data/16bit_numbers/$image.txt";
    open INFILE, $infile or die "Can't open $infile.\n";

    print OUTFILE "insert into input_images values ( $input_id, $image );\n";

    while ( $row = <INFILE> ) {

        chomp( $row );

        my @row_arr = split //, $row;
        my $column_counter;

        print OUTFILE "insert into input_images_row values ( $input_id, $image, $row_counter );\n";

        print OUTFILE "insert into input_images_row_col values ( $input_id, $image, $row_counter";

        for ( $column_counter = 0 ; $column_counter < $NUM_COLUMNS ; $column_counter++ ) {

            print OUTFILE ", $row_arr[$column_counter]";
        }

        print OUTFILE ");\n";

        $row_counter++
    }

    $neuron_id = $image+1; 

    print OUTFILE "insert into object values ( $neuron_id, 2, 2, \"neuron_$image\", 0, 1 );\n";
    print OUTFILE "insert into neuron values ( $neuron_id, 0.5, 3, $image, 0.2, $input_id );\n";

    close INFILE;
}

print OUTFILE "insert into object values ( $monitor_id, 3, 3, \"monitor\", 0, 1 );\n";
print OUTFILE "insert into monitor values ( $monitor_id, $input_id );\n";
print OUTFILE "insert into monitor_neurons values ( $monitor_id";

for $image ( @images ) {

    $neuron_id = $image+1; 
    print OUTFILE ", $neuron_id";
}

print OUTFILE " );\n";

close OUTFILE;


