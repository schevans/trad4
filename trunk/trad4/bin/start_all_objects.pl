#!/usr/bin/perl

my $file;



my @files = `cd $ENV{DATA_DIR} && ls *.t4o`;

foreach $file ( @files ) {

    chomp( $file );

    my ( $id, $type, $suffix ) = split /\./, $file;

    system( "$ENV{TRAD4_ROOT}/bin/object $id $type" );

    sleep( 1 );
}



