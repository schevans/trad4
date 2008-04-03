#!/usr/bin/perl

#use warnings;
#use Data::Dumper;

if ( !$ENV{INSTANCE_ROOT} ) {

    print "INSTANCE_ROOT not set. Exiting\n";
    exit 1;
}

my $gen_root=$ENV{INSTANCE_ROOT}."/gen";


sub load_defs($);
sub print_accessors($$);

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


foreach $name ( keys %{object_hash} ) {

    my $filename = $name."_macros.h";

    open FILE, ">$gen_root/objects/$filename" or die "Can't open $gen_root/objects/$filename for writing. Exiting";

    print_accessors( $name, FILE );

    close FILE;

}

#print Dumper( %object_hash );

sub print_accessors($$) {
    my $name = shift;
    my $FILEHANDLE = shift;


        foreach $var ( keys %{$object_hash{$name}{pub}} ) {

            print $FILEHANDLE "#define $name"."_$var (($name*)obj_loc[id])->$var\n"; 

        }

        foreach $var ( keys %{$object_hash{$name}{static}} ) {

            print $FILEHANDLE "#define $name"."_$var (($name*)obj_loc[id])->$var\n"; 

        }


        foreach $var ( keys %{$object_hash{$name}{sub}} ) {

            foreach $var2 ( keys %{$object_hash{$var}{pub}} ) {

                print $FILEHANDLE "#define $var"."_$var2 (($var*)obj_loc[(($name*)obj_loc[id])->$var])->$var2\n"; 
            }

            foreach $var2 ( keys %{$object_hash{$var}{static}} ) {

                print $FILEHANDLE "#define $var"."_$var2 (($var*)obj_loc[(($name*)obj_loc[id])->$var])->$var2\n"; 
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

        if ( $line =~ /sub|pub|static/ ) {

            $section = $line;
            next;
        }

        ( $type, $var ) = split / /, $line;

        $object_hash{$name}{$section}{$var} = $type;
    }

    close FILE;

}

