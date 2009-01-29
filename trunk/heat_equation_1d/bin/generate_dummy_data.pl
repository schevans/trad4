#!/usr/bin/perl

# Copyright (c) Steve Evans 2009
# steve@topaz.myzen.co.uk
# This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

use warnings;
use strict;

my $length = 10;
my $k = 0.1;
my $alpha = 1.0;
my $beta = 0;
my $converged_limit = 1.0e-6;
my $diverged_limit = 1.0;

my $data_server_id = 99999;
my $monitor_id = 99998;

my $dummy_data_root="$ENV{APP_ROOT}/data/gen_data";

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

    print FILE "insert into object values ( $counter, 2, \"element_$counter\", 0, 1 );\n";

    print FILE "insert into element values ( $counter, 0, $element_type, $change_id );\n";

    $counter = $counter + 1;
}

close FILE;

$file = "$dummy_data_root/change.sql";

open FILE, ">$file" or die "Can't open $file";

print FILE "delete from change;\n";


while ( $counter <= $length * 2 ) {

    print FILE "insert into object values ( $counter, 3, \"change_$counter\", 0, 1 );\n";

    my $sub_this = $counter - $length;
    my $sub_up = $counter - $length + 1;
    my $sub_down = $counter - $length - 1;

    if ( $sub_down == 0 ) {
        $sub_down = 1;
    }

    if ( $sub_up == $length + 1 ) {
        $sub_up = $length;
    }

    print FILE "insert into change values ( $counter, $data_server_id, $sub_up, $sub_this, $sub_down );\n";

    $counter = $counter + 1;
}

close FILE;

$file = "$dummy_data_root/data_server.sql";

open FILE, ">$file" or die "Can't open $file";

print FILE "delete from data_server;\n";

print FILE "insert into object values ( $data_server_id, 1, \"data_server\", 0, 1 );\n";

print FILE "insert into data_server values ( $data_server_id, $k, $alpha, $beta );\n";

close FILE;

$file = "$dummy_data_root/monitor.sql";

open FILE, ">$file" or die "Can't open $file";

print FILE "delete from monitor;\n";
print FILE "insert into object values ( $monitor_id, 4, \"monitor\", 0, 1 );\n";
print FILE "insert into monitor values ( $monitor_id, 0, 0, $converged_limit, $diverged_limit, $data_server_id );\n";

close FILE;

my $changes_file = "$dummy_data_root/monitor_my_changes.sql";
my $elements_file = "$dummy_data_root/monitor_my_elements.sql";

open CHANGES_FILE, ">$changes_file" or die "Can't open $changes_file";
open ELEMENTS_FILE, ">$elements_file" or die "Can't open $elements_file";

print CHANGES_FILE "delete from monitor_my_changes;\n";
print ELEMENTS_FILE "delete from monitor_my_elements;\n";

$counter = 1;

while ( $counter <= $length ) {


    print CHANGES_FILE "insert into monitor_my_changes values ( $monitor_id, ".($length+$counter)." );\n";
    print ELEMENTS_FILE "insert into monitor_my_elements values ( $monitor_id, ".$counter." );\n";

    $counter = $counter+1;
}

close CHANGES_FILE;
close ELEMENTS_FILE;

