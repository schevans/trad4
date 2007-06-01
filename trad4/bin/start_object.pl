#!/usr/bin/perl

if ( $#ARGV != 0 ) {
    print "usage $basename <filename|id>\n";
    exit 1;
}

my $filename = $ARGV[0];

my ( $prefix, $type, $suffix ) = split /\./, $filename;

my $id =~ s/^.*/[0-9]*/

print "$filename:  $id, $type, $suffix\n";

system( "$ENV{TRAD4_ROOT}/bin/object $id $type" );


