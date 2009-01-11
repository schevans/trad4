#!/usr/bin/perl

# Copyright (c) Steve Evans 2009
# steve@topaz.myzen.co.uk
# This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

use warnings;
use strict;

my $length = 10;

sub funk($) {
    my $x = shift;

    return $x/$length;
}


my $dummy_data_root="$ENV{APP_ROOT}/data/dummy_data";

if ( ! -d $dummy_data_root ) {

    print "Creating directory $dummy_data_root\n";
    mkdir( $dummy_data_root );
}


my $file = $dummy_data_root."/element.sql";

open FILE, ">$file" or die "Can't open $file";

print FILE "delete from element;\n";

my $counter = 1;
my $element_type;
my $change_id;

while ( $counter <= $length ) {

    if ( $counter == 1 ) {
        $element_type = 0;
    }
    elsif ( $counter == $length ) {
        $element_type = 2;
    }
    else {
        $element_type = 1;
    }

    $change_id = $counter+$length;

    print FILE "insert into object values ( $counter, 1, \"element_$counter\", 0, 1 );\n";

    print FILE "insert into element values ( $counter, 0, $element_type, ".funk( $counter ).", $change_id );\n";

    $counter = $counter + 1;
}

close FILE;

$file = "$dummy_data_root/change.sql";

open FILE, ">$file" or die "Can't open $file";

print FILE "delete from change;\n";


while ( $counter <= $length * 2 ) {

    print FILE "insert into object values ( $counter, 2, \"change_$counter\", 0, 1 );\n";

    my $sub_this = $counter - $length;
    my $sub_up = $counter - $length + 1;
    my $sub_down = $counter - $length - 1;

    if ( $sub_down == 0 ) {
        $sub_down = 1;
    }

    if ( $sub_up == $length + 1 ) {
        $sub_up = $length;
    }

    print FILE "insert into change values ( $counter, $sub_up, $sub_this, $sub_down );\n";

    $counter = $counter + 1;
}

close FILE;

