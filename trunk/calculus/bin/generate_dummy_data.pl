#!/usr/bin/perl

# Copyright (c) Steve Evans 2007
# steve@topaz.myzen.co.uk
# This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

use warnings;
use strict;

my $length = 100;

my $dummy_data_root="$ENV{APP_ROOT}/data/dummy_data";

sub funk($) {
    my $x = shift;

    return $x/$length;
}

if ( ! -d $dummy_data_root ) {

    print "Creating directory $dummy_data_root\n";
    mkdir( $dummy_data_root );
}


my $file = $dummy_data_root."/f.sql";

open FILE, ">$file" or die "Can't open $file";

print FILE "delete from f;\n";

my $counter = 1;

while ( $counter <= $length ) {

    print FILE "insert into object values ( $counter, 1, \"f_$counter\", 1, 1 );\n";

    my $node_type_enum = 1;

    if ( $counter == 1 ) {
        $node_type_enum = 0;
    }

    if ( $counter == $length ) {
        $node_type_enum = 2;
    }

    print FILE "insert into f values ( $counter, ".funk( $counter ).", $node_type_enum );\n";

    $counter = $counter + 1;
}

close FILE;

$file = "$dummy_data_root/df.sql";

open FILE, ">$file" or die "Can't open $file";

print FILE "delete from df;\n";


while ( $counter <= $length * 2 ) {

    print FILE "insert into object values ( $counter, 2, \"df_1\", 1, 1 );\n";

    my $sub_up = $counter - $length + 1;
    my $sub_down = $counter - $length - 1;
    my $node_type_enum = 1;

    if ( $sub_down == 0 ) {
        $sub_down = 2;
        $node_type_enum = 0;
    }

    if ( $sub_up == $length + 1 ) {
        $sub_up = $length - 1;
        $node_type_enum = 2;
    }

    print FILE "insert into df values ( $counter, $node_type_enum, $sub_up, $sub_down );\n";

    $counter = $counter + 1;
}

close FILE;

$file = "$dummy_data_root/d2f.sql";

open FILE, ">$file" or die "Can't open $file";

print FILE "delete from d2f;\n";

while ( $counter <= $length * 3 ) {

    print FILE "insert into object values ( $counter, 3, \"d2f_1\", 1, 1 );\n";

    my $sub_up = $counter - $length + 1;
    my $sub_down = $counter - $length - 1;
    my $node_type_enum = 1;

    if ( $sub_down == $length ) {
        $sub_down = $length + 2;
        $node_type_enum = 0;
    }

    if ( $sub_up == ($length*2) + 1 ) {
        $sub_up = ($length*2) - 1;
        $node_type_enum = 2;
    }

    print FILE "insert into d2f values ( $counter, $node_type_enum, $sub_up, $sub_down );\n";

    $counter = $counter + 1;
}

close FILE;

