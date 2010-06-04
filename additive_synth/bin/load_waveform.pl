#!/usr/bin/perl

# Copyright (c) Steve Evans 2010
# steve@topaz.myzen.co.uk
# This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

use warnings;
use strict;

use Data::Dumper;

use PreComp::AppConstants;
use PreComp::Utilities;

if ( $#ARGV != 1 ) {

    print "Usage: load_waveform.pl <filename> <frequency>\n";
    exit(1);
}

my $input_filename=$ARGV[0];
my $base_frequency=$ARGV[1];

my $constants_hash;

if (  -f $ENV{SRC_DIR}."/constants.t4s" ) {

    $constants_hash = PreComp::Utilities::LoadAppConstants();
}

my $NUM_HARMONICS = $constants_hash->{NUM_HARMONICS};

my @waveform;

for ( my $id=1 ; $id <= $NUM_HARMONICS ; $id++ ) {

    $waveform[$id] = 0.0;
}

open INFILE, "$input_filename" or die "Can't open $input_filename.";

my $line;

`echo "delete from waveform_amplitude;" | $ENV{SQLITE} $ENV{APP_DB}`;

my $i=1;



while ( $line = <INFILE> ) {

    chomp $line;

    if ( $line ) {

        my ( $id, $amplitude ) = split /,/, $line;

        $waveform[$id] = $amplitude 
    }
}

my $sqlstring = "insert into waveform_amplitude values ( 8888"; 

for ( my $id=1 ; $id <= $NUM_HARMONICS ; $id++ ) {

    $sqlstring = $sqlstring.", $waveform[$id]";
}

$sqlstring = $sqlstring." );";

`echo "$sqlstring" | $ENV{SQLITE} $ENV{APP_DB}`;

close INFILE;

`echo "update waveform set base_frequency=$base_frequency;" | $ENV{SQLITE} $ENV{APP_DB}`;

my $result=`$ENV{TRAD4_BIN}/send_reload.sh`;

print "$result";

