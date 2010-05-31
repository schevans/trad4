#!/usr/bin/perl

# Copyright (c) Steve Evans 2010
# steve@topaz.myzen.co.uk
# This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

use warnings;
use strict;

use Data::Dumper;

use PreComp::AppConstants;
use PreComp::Utilities;

if ( $#ARGV != 0 ) {

    print "Usage: load_waveform.pl <filename>\n";
    exit(1);
}

my $input_filename=$ARGV[0];

my $constants_hash;

if (  -f $ENV{SRC_DIR}."/constants.t4s" ) {

    $constants_hash = PreComp::Utilities::LoadAppConstants();
}

my $NUM_HARMONICS = $constants_hash->{NUM_HARMONICS};

open INFILE, "$input_filename" or die "Can't open $input_filename.";

my $line;

`echo "delete from waveform_amplitude;" | $ENV{SQLITE} $ENV{APP_DB}`;

my $i=1;

my $sqlstring = "insert into waveform_amplitude values ( 8888"; 

for ( my $i=1 ; $i <= $NUM_HARMONICS ; $i++ ) {

    if ( $line = <INFILE> ) {

        chomp $line;

        $sqlstring = $sqlstring.", $line";
    }
    else {

        $sqlstring = $sqlstring.", 0";
    }
}

$sqlstring = $sqlstring." );";

`echo "$sqlstring" | $ENV{SQLITE} $ENV{APP_DB}`;

close INFILE;

