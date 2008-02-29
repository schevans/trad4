#!/usr/bin/perl

# Copyright (c) Steve Evans 2007
# steve@topaz.myzen.co.uk
# This code is licenced under the LGPL. For details see $TRAD4_ROOT/LICENCE

use warnings;

if ( !$ENV{TRAD4_ROOT} ) {

    print "TRAD4_ROOT not set. Exiting\n";
    exit 1;
}

if ( @ARGV != 1 ) {
    print "usage: generate_stubs.pl <object_name>\n";
    exit 1;
}

my $name = $ARGV[0];

my $is_feed=0;

if ( $name =~ /feed/ ) {
    $is_feed = 1;
}

my $h_filename = "$name.h";
my $c_filename = "$name.c";

my ( @sub, @pub, @mem_pub, @static, @static_vec, @common, @header );

@header = ( "ulong last_published",
            "object_status status",
            "void* (*calculator_fpointer)(void*)",
            "bool (*need_refresh_fpointer)(int)",
            "int type" ,
            "char name[OBJECT_NAME_LEN]"
            
        );

my $defs_root=$ENV{INSTANCE_ROOT}."/defs";
my $gen_root=$ENV{INSTANCE_ROOT};
my $obj_root=$ENV{INSTANCE_ROOT}."/objects";


sub generate_header();
sub load_defs($);

open TYPES_FILE, "$ENV{INSTANCE_ROOT}/defs/object_types.t4s" or die "Can't open $ENV{INSTANCE_ROOT}/defs/object_types.t4s for reading";

my ( $line, $num, $type );
my %types_map;
while ( $line = <TYPES_FILE> ) {

    chomp $line;

    if ( !$line or $line =~ /#/ ) {
        next;
    }

    ( $num, $type ) = split /,/, $line;
    $types_map{$type} = $num;
}

close TYPES_FILE;

load_defs( "$defs_root/$name.t4" );

generate_header();

sub generate_header()
{
    open PUB_STRUCT_FILE, ">$gen_root/objects/$h_filename" or die "Can't open $gen_root/objects/$h_filename for writing. Exiting";

    #print_licence_header( PUB_STRUCT_FILE );

    print PUB_STRUCT_FILE "\n";
    print PUB_STRUCT_FILE "#ifndef __$name"."__\n";
    print PUB_STRUCT_FILE "#define __$name"."__\n";
    print PUB_STRUCT_FILE "\n";
    print PUB_STRUCT_FILE "#include <sys/types.h>\n";
    print PUB_STRUCT_FILE "#include \"trad4.h\"\n";
    print PUB_STRUCT_FILE "\n";
    print PUB_STRUCT_FILE "typedef struct {\n";

    print PUB_STRUCT_FILE "    // Header\n";

    foreach $tuple ( @header, @common ) {

        ( $type, $var ) = split / /, $tuple;

        print PUB_STRUCT_FILE "    $type $var;\n";

    }

    print PUB_STRUCT_FILE "\n";
    print PUB_STRUCT_FILE "    // Sub\n";

    foreach $tuple ( @sub ) {

        ( $type, $var ) = split / /, $tuple;

        print PUB_STRUCT_FILE "    int $var;\n";

    }

    print PUB_STRUCT_FILE "\n";
    print PUB_STRUCT_FILE "    // Static\n";

    foreach $tuple ( @static ) {

        ( $type, $var ) = split / /, $tuple;

        print PUB_STRUCT_FILE "    $type $var;\n";

    }

    print PUB_STRUCT_FILE "\n";
    print PUB_STRUCT_FILE "    // Pub\n";

    foreach $tuple ( @pub, @mem_pub ) {

        ( $type, $var ) = split / /, $tuple;

        print PUB_STRUCT_FILE "    $type $var;\n";

    }


    print PUB_STRUCT_FILE "} $name;\n";
    print PUB_STRUCT_FILE "\n";
    print PUB_STRUCT_FILE "#endif\n";

    close PUB_STRUCT_FILE;
}

sub load_defs($) {
    my $file = shift;

    open FILE, "$file" or die "Could not open $file";


    my $line;

    my $doing;



    while ( $line = <FILE> ) {

        chomp $line;

        if ( !$line or $line =~ /#/ ) {
            next;
        }

        if ( $line =~ /sub|pub|static/ ) {

            $doing = $line;
            next;
        }
        if ( $doing =~ /sub/ ) {

            push @sub, trim( $line );

        }
        elsif ( $doing =~ /pub/ ) {

            $line =~ s/^ *//;

            if ( $line =~ '\[' ) {
                push @mem_pub, trim( $line );
            }
            else {
                push @pub, trim( $line );
            }
        }
        elsif ( $doing =~ /static/ ) {

            if ( $line =~ '\[' ) {
                push @static_vec, trim( $line );
            }
            else {
                push @static, trim( $line );
            }
        }
        else {
            die "Error: Unknown label $doing.";
        }

    }

    close FILE;

}

sub trim($) {
    my $str = shift;

    $str =~ s/\s+$//;
    $str =~ s/^\s+//;

    return $str;
}

