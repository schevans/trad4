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
my $table_filename = "$name.table";

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


#sub generate_h();
sub generate_c();
sub load_defs($);
sub cpp2sql_type($);
sub generate_table();

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

generate_h();
generate_table();

if ( ! -f "$obj_root/$c_filename" ) {
    generate_c();
}

exit 0;

sub generate_h()
{
    open H_FILE, ">$gen_root/objects/$h_filename" or die "Can't open $gen_root/objects/$h_filename for writing. Exiting";

    #print_licence_header( H_FILE );

    print H_FILE "\n";
    print H_FILE "#ifndef __$name"."__\n";
    print H_FILE "#define __$name"."__\n";
    print H_FILE "\n";
    print H_FILE "#include <sys/types.h>\n";
    print H_FILE "\n";
    print H_FILE "#include \"common.h\"\n";
    print H_FILE "\n";
    print H_FILE "typedef struct {\n";

    print H_FILE "    // Header\n";

    foreach $tuple ( @header, @common ) {

        ( $type, $var ) = split / /, $tuple;

        print H_FILE "    $type $var;\n";

    }

    print H_FILE "\n";
    print H_FILE "    // Sub\n";

    foreach $tuple ( @sub ) {

        ( $type, $var ) = split / /, $tuple;

        print H_FILE "    int $var;\n";

    }

    print H_FILE "\n";
    print H_FILE "    // Static\n";

    foreach $tuple ( @static ) {

        ( $type, $var ) = split / /, $tuple;

        print H_FILE "    $type $var;\n";

    }

    print H_FILE "\n";
    print H_FILE "    // Pub\n";

    foreach $tuple ( @pub, @mem_pub ) {

        ( $type, $var ) = split / /, $tuple;

        print H_FILE "    $type $var;\n";

    }


    print H_FILE "} $name;\n";
    print H_FILE "\n";
    print H_FILE "#endif\n";

    close H_FILE;
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

sub generate_c()
{
    open C_FILE, ">$gen_root/objects/$c_filename" or die "Can't open $gen_root/objects/$c_filename for writing. Exiting";

    #print_licence_header( C_FILE );

    print C_FILE "\n";
    print C_FILE "#include \"trad4.h\"\n";
    print C_FILE "#include \"$name.h\"\n";
    print C_FILE "\n";
    print C_FILE "extern void* obj_loc[NUM_OBJECTS+1];\n";
    print C_FILE "\n";
    print C_FILE "void* calculate_$name( void* id )\n";
    print C_FILE "{\n";
    print C_FILE "\n";
    print C_FILE "}\n";
    print C_FILE "\n";
    print C_FILE "bool ".$name."_need_refresh( int id )\n";
    print C_FILE "{\n";

    print C_FILE "    return ( ";

    foreach $tuple ( @sub ) {

        ( $type, $var ) = split / /, $tuple;

        print C_FILE "(((object_header*)obj_loc[id])->status == STOPPED ) && ( *(int*)obj_loc[id] < *(int*)obj_loc[(($name*)obj_loc[id])->$var] ) || ";  


    }

    print C_FILE " 0 );\n";




    print C_FILE "}\n";

    close C_FILE;
}

sub generate_table() {
    
    open TABLE_FILE, ">$gen_root/sql/$table_filename" or die "Can't open $gen_root/objects/$table_filename for writing. Exiting";

    my $tuple;
    my ( $column, $type );

    print TABLE_FILE "create table $name (\n";
    print TABLE_FILE "    id int";

    foreach $tuple ( @static ) {

        ( $type, $column ) = split / /, $tuple;

        print TABLE_FILE ",\n    $column ".cpp2sql_type( $type );
    }

    foreach $tuple ( @sub ) {

        ( $type, $var ) = split / /, $tuple;

        print TABLE_FILE ",\n    $var int";
    }

    print TABLE_FILE "\n";
    print TABLE_FILE ")\n";
    print TABLE_FILE "\n";

    close TABLE_FILE;
}

sub cpp2sql_type($) {
    my $cpp_type = shift;

    my $sql_type;

    if ( $cpp_type =~ 'double' ) {
        $sql_type = "float";
    }
    else {
        $sql_type = "int";
    }
   
    return $sql_type;
}



