#!/usr/bin/perl

use warnings;
use Data::Dumper;

if ( !$ENV{INSTANCE_ROOT} ) {

    print "INSTANCE_ROOT not set. Exiting\n";
    exit 1;
}

my $gen_root=$ENV{INSTANCE_ROOT}."/gen";


sub load_defs($);
my %object_hash;

open TYPES_FILE, "$ENV{INSTANCE_ROOT}/defs/object_types.t4s" or die "Can't open $ENV{INSTANCE_ROOT}/defs/object_types.t4s for reading";

while ( $line = <TYPES_FILE> ) {

    chomp $line;

    if ( !$line or $line =~ /#/ ) {
        next;
    }

    ( $num, $tier, $type ) = split /,/, $line;

    load_defs( $type );
}

close TYPES_FILE;

#print Dumper( %object_hash );

foreach $object ( keys %object_hash ) {

    foreach $sub ( keys %{$object_hash{$object}{sub}} ) {

        my $file = "$ENV{INSTANCE_ROOT}/objects/$object.c";

        my $found = `grep $sub $file`;

        if ( ! $found ) {

            print "Warning: $object has $sub listed in t4 file as sub but not used in $object.c\n";

        }

    }
}


sub load_defs($) {
    my $name = shift;

    my $file = $ENV{INSTANCE_ROOT}."/defs/$name.t4";

    open FILE, "$file" or die "Could not open $file for reading";


    my $line;
    my $section;

    my ( $type, $var );

    while ( $line = <FILE> ) {

        chomp $line;

        if ( !$line or $line =~ /#/ ) {
            next;
        }

        $line =~ s/^\s+//;
        $line =~ s/\s+$//;

        if ( $line =~ /sub|pub|static|feed_in|feed_out/ ) {

            if ( $line =~ /feed_in/ ) {

                $section = "static";
            }
            elsif ( $line =~ /feed_out/ ) {

                $section = "pub";
            }
            else {
                $section = $line;
            }

            next;
        }

        ( $type, $var ) = split / /, $line;

        $object_hash{$name}{$section}{$var} = $type;
    }
    close FILE;

}

