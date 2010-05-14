#!/usr/bin/perl

# Copyright (c) Steve Evans 2010
# steve@topaz.myzen.co.uk
# This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

use warnings;
use strict;

use Data::Dumper;

use PreComp::AppConstants;
use PreComp::Utilities;


my $constants_hash;

if (  -f $ENV{SRC_DIR}."/constants.t4s" ) {

    $constants_hash = PreComp::Utilities::LoadAppConstants();
}

my $NUM_CORRELATORS = $constants_hash->{NUM_CORRELATORS};

my $source_id = 9999;
my $monitor_id = 8888;

my $FHD = PreComp::Utilities::OpenFile(  $ENV{APP_ROOT}."/data/worked_example/gen.sql" );

print $FHD "BEGIN;\n";
print $FHD "delete from object;\n";
print $FHD "delete from source;\n";
print $FHD "delete from correlator;\n";
print $FHD "delete from monitor;\n";
print $FHD "delete from monitor_correlators;\n";



print $FHD "insert into object values ( $source_id, 1, 1, \"source\", 1, 1 );\n";
print $FHD "insert into source values ( $source_id );\n";

print $FHD ";\n";

my $current_id = 1;

for ( ; $current_id <= $NUM_CORRELATORS ; $current_id++ )
{
    print $FHD "insert into object values ( $current_id, 2, 2, \"correlator_$current_id\", 1, 1 );\n";
    print $FHD "insert into correlator values ( $current_id, $source_id );\n";
}

print $FHD ";\n";


print $FHD "insert into object values ( $monitor_id, 3, 3, \"monitor\", 1, 1 );\n";
print $FHD "insert into monitor values ( $monitor_id );\n";

$current_id = 1;

print $FHD "insert into monitor_correlators values ( $monitor_id";

for ( ; $current_id <= $NUM_CORRELATORS ; $current_id++ )
{
    print $FHD ", $current_id";
}

print $FHD " );";

print $FHD "COMMIT;\n";

PreComp::Utilities::CloseFile();



