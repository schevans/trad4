#!/usr/bin/perl

# Copyright (c) Steve Evans 2010
# steve@topaz.myzen.co.uk
# This code is licenced under the BSD licence. For details see $APP_ROOT/LICENCE

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

if ( ! -f $input_filename ) {

    print "Error: Can't find $input_filename.\n";
    exit(1);
}

`cp $input_filename $ENV{APP_ROOT}/source.wav`;

`echo "update source set base_frequency=$base_frequency;" | $ENV{SQLITE} $ENV{APP_DB}`;

my $is_running = `ps -C $ENV{APP} | grep -v PID | wc -l`;

chomp( $is_running );

if ( $is_running ) {

    print "Sending reload signal.\n";

    `$ENV{TRAD4_BIN}/send_reload.sh`;
}

