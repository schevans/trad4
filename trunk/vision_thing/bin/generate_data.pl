#!/usr/bin/perl

# Copyright (c) Steve Evans 2009
# steve@topaz.myzen.co.uk
# This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

use warnings;
use strict;

my $outfile = $ENV{APP_ROOT}."/data/64bit_numbers/gen.sql";
open OUTFILE, ">$outfile" or die "Can't open $outfile.\n";

my $row;

my $NUM_ROWS = 16;
my $NUM_COLUMNS = 16;

my $input_id = 9999;
my $monitor_id = 10000;

my @image;

print OUTFILE "BEGIN;\n";
print OUTFILE "delete from object;\n";
print OUTFILE "delete from input;\n";
print OUTFILE "delete from neuron;\n";

print OUTFILE "insert into object values ( $input_id, 1, 1, \"input\", 0, 1 );\n";
print OUTFILE "insert into input values ( $input_id, $monitor_id );\n";
print OUTFILE "insert into input_font_order values ( $input_id, 0, 1, 2 );\n";

my $image;
my $neuron_id;

my @images = ( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 );

for $image ( @images ) {

    $neuron_id = $image+1; 

    print OUTFILE "insert into object values ( $neuron_id, 2, 2, \"neuron_$image\", 0, 1 );\n";
    print OUTFILE "insert into neuron values ( $neuron_id, $image, $input_id );\n";

}

print OUTFILE "insert into object values ( $monitor_id, 3, 3, \"monitor\", 0, 1 );\n";
print OUTFILE "insert into monitor values ( $monitor_id, $input_id );\n";
print OUTFILE "insert into monitor_neurons values ( $monitor_id";

for $image ( @images ) {

    $neuron_id = $image+1; 
    print OUTFILE ", $neuron_id";
}

print OUTFILE " );\n";
print OUTFILE "COMMIT;\n";

close OUTFILE;


