#!/usr/bin/perl

# Copyright (c) Steve Evans 2007
# steve@topaz.myzen.co.uk
# This code is licenced under the LGPL. For details see $TRAD4_ROOT/LICENCE

use strict;
use warnings;


if ( $#ARGV != 0 ) {
    print "usage start_object.pl <filename|id>\n";
    exit 1;
}

my $arg = $ARGV[0];

my $filename;

if ( $arg =~ /\.t4o/ ) {
   $filename = $arg; 
}
else {
    $filename = `cd $ENV{DATA_DIR}; ls $arg.*.t4o`;
}

my @array = split /\./, $filename;

my ( $id, $type, $suffix ) = split /\./, $filename;

system( "$ENV{TRAD4_ROOT}/bin/object $id $type" );

