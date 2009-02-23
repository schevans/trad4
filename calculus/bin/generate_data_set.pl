#!/usr/bin/perl

# Copyright (c) Steve Evans 2007
# steve@topaz.myzen.co.uk
# This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

use warnings;
use strict;

if ( $#ARGV != 0 )
{
    print "generate_data_set.pl <num_nodes>\n";
    exit 0;
}

my $length = $ARGV[0];
my $monitor_id = 999999;

my $dummy_data_root="$ENV{APP_ROOT}/data/generated_data_set";

if ( ! -d $dummy_data_root ) {

    print "Creating directory $dummy_data_root\n";
    mkdir( $dummy_data_root );
}


my $file = $dummy_data_root."/f.sql";

open FILE, ">$file" or die "Can't open $file";

print FILE "delete from f;\n";
print FILE "BEGIN;\n";

my $counter = 1;

while ( $counter <= $length ) {

    print FILE "insert into object values ( $counter, 1, 1, \"f_$counter\", 0, 1 );\n";

    print FILE "insert into f values ( $counter, 0 );\n";

    $counter = $counter + 1;
}

print FILE "COMMIT;\n";
close FILE;

$file = "$dummy_data_root/df.sql";

open FILE, ">$file" or die "Can't open $file";

print FILE "delete from df;\n";
print FILE "BEGIN;\n";


while ( $counter <= $length * 2 ) {

    print FILE "insert into object values ( $counter, 2, 2, \"df_1\", 0, 1 );\n";

    my $sub_up = $counter - $length + 1;
    my $sub_this = $counter - $length;
    my $sub_down = $counter - $length - 1;

    if ( $sub_down == 0 ) {
        $sub_down = 1;
    }

    if ( $sub_up == $length + 1 ) {
        $sub_up = $length;
    }

    print FILE "insert into df values ( $counter, $sub_down, $sub_this, $sub_up );\n";

    $counter = $counter + 1;
}

print FILE "COMMIT;\n";
close FILE;

$file = "$dummy_data_root/d2f.sql";

open FILE, ">$file" or die "Can't open $file";

print FILE "delete from d2f;\n";
print FILE "BEGIN;\n";

while ( $counter <= $length * 3 ) {

    print FILE "insert into object values ( $counter, 3, 3, \"d2f_1\", 0, 1 );\n";

    my $sub_up = $counter - $length + 1;
    my $sub_this = $counter - $length;
    my $sub_down = $counter - $length - 1;

    if ( $sub_down == $length ) {
        $sub_down = $length + 1;
    }

    if ( $sub_up == ($length*2) + 1 ) {
        $sub_up = ($length*2);
    }

    print FILE "insert into d2f values ( $counter, $sub_down, $sub_this, $sub_up );\n";

    $counter = $counter + 1;
}

print FILE "COMMIT;\n";
close FILE;

$file = "$dummy_data_root/monitor.sql";

open FILE, ">$file" or die "Can't open $file";

print FILE "delete from monitor;\n";
print FILE "insert into object values ( $monitor_id, 4, 4, \"monitor\", 0, 1 );\n";
print FILE "insert into monitor values ( $monitor_id );\n";

close FILE;

my $monitor_my_f_file = "$dummy_data_root/monitor_my_f.sql";
my $monitor_my_df_file = "$dummy_data_root/monitor_my_df.sql";
my $monitor_my_d2f_file = "$dummy_data_root/monitor_my_d2f.sql";

open MON_F, ">$monitor_my_f_file" or die "Can't open $monitor_my_f_file";
open MON_DF, ">$monitor_my_df_file" or die "Can't open $monitor_my_df_file";
open MON_D2F, ">$monitor_my_d2f_file" or die "Can't open $monitor_my_d2f_file";

print MON_F "delete from monitor_my_f;\n";
print MON_F "BEGIN;\n";
print MON_DF "delete from monitor_my_df;\n";
print MON_DF "BEGIN;\n";
print MON_D2F "delete from monitor_my_d2f;\n";
print MON_D2F "BEGIN;\n";

$counter = 1;

while ( $counter <= $length ) {

    print MON_F "insert into monitor_my_f values ( $monitor_id, $counter );\n";
    print MON_DF "insert into monitor_my_df values ( $monitor_id, ".($counter+$length)." );\n";
    print MON_D2F "insert into monitor_my_d2f values ( $monitor_id, ".($counter+($length*2))." );\n";

    $counter = $counter+1;
}

print MON_F "COMMIT;\n";
close MON_F;
print MON_DF "COMMIT;\n";
close MON_DF;
print MON_D2F "COMMIT;\n";
close MON_D2F;

