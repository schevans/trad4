#!/usr/bin/perl

my $file;

my @object_types = ( split( /,/, $ENV{OBJ_TYPE_START_ORDER}) );

my $object_type;

foreach $object_type ( @object_types ) {

    my @files = `cd $ENV{DATA_DIR} && ls *.$object_type.t4o`;

    foreach $file ( @files ) {

        chomp( $file );

        my ( $id, $type, $suffix ) = split /\./, $file;

        system( "$ENV{TRAD4_ROOT}/bin/object $id $type" );

        select undef, undef, undef, 0.1;
    }

}

