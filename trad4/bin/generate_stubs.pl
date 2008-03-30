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
my $loader_filename = "load_$name.c";
my $c_wrapper_filename = "$name"."_wrapper.c";
my $table_filename = "$name.table";
my $dummy_data_filename = "$name.sql";

my ( @sub, @pub, @mem_pub, @static, @static_vec, @header );

@header = ( "ulong last_published",
            "object_status status",
            "int id",
            "void* (*calculator_fpointer)(void*)",
            "bool (*need_refresh_fpointer)(int)",
            "int type" ,
            "char name[OBJECT_NAME_LEN]",
            "int log_level"
            
        );

my $defs_root=$ENV{INSTANCE_ROOT}."/defs";
my $gen_root=$ENV{INSTANCE_ROOT}."/gen";
my $obj_root=$ENV{INSTANCE_ROOT}."/objects";
my $dummy_data_root=$ENV{INSTANCE_ROOT}."/data/default_set";

sub generate_h();
sub generate_c();
sub generate_loader();
sub generate_c_wrapper();
sub load_defs($);
sub cpp2sql_type($);
sub generate_table();
sub generate_dummy_data();

open TYPES_FILE, "$ENV{INSTANCE_ROOT}/defs/object_types.t4s" or die "Can't open $ENV{INSTANCE_ROOT}/defs/object_types.t4s for reading";

my ( $line, @line_array, $type_num, $type_name, $tier );
my %types_map;
while ( $line = <TYPES_FILE> ) {

    chomp $line;

    if ( !$line or $line =~ /#/ ) {
        next;
    }

    @line_array = split /,/, $line;

    $type_num = $line_array[0]; 
    $type_name = $line_array[2]; 

    $types_map{$type_name} = $type_num;

    if ( "$type_name" =~ "$name" ) {

        $tier = $line_array[1];
    }
}

close TYPES_FILE;

load_defs( "$defs_root/$name.t4" );

generate_h();
generate_table();
generate_c_wrapper();
generate_loader();

if ( ! -f "$obj_root/$c_filename" ) {
    generate_c();
}

if ( ! -f "$dummy_data_root/$dummy_data_filename" ) {
    generate_dummy_data();
}


sub generate_dummy_data()
{
    open FILE, ">$dummy_data_root/$dummy_data_filename" or die "Can't open $dummy_data_root/$dummy_data_filename for writing. Exiting";

    my $tupe_num = $types_map{$name};

    print FILE "delete from $name;\n";
    print FILE "insert into object values ( $tupe_num, $tupe_num, \"$name"."_$tupe_num\", 0 );\n";
    print FILE "insert into $name values ( $tupe_num";

    if ( @static ) {

        foreach $tuple ( @static ) {

            print FILE ", 0";
        }
    }

    if ( ! $is_feed ) {

        foreach $tuple ( @sub ) {

            ( $type, $var ) = split / /, $tuple;

            print FILE ", $types_map{$var}";

        }
    }

    print FILE " );\n";

    close FILE;
}

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

    if ( $is_feed ) {

        print H_FILE "typedef struct {\n";

        foreach $tuple ( @pub, @mem_pub ) {

            ( $type, $var ) = split / /, $tuple;

            print H_FILE "    $type $var;\n";

        }

        print H_FILE "    int last_published;\n";
        print H_FILE "} $name"."_sub;\n";
        print H_FILE "\n";

    }

    print H_FILE "typedef struct {\n";

    print H_FILE "    // Header\n";

    foreach $tuple ( @header ) {

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

    if ( $is_feed ) {

        print H_FILE "    int shmid;\n";
        print H_FILE "    $name"."_sub* sub;\n";
    }

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

    open FILE, "$file" or die "Could not open $file for reading";


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

sub generate_loader()
{

    open C_FILE, ">$gen_root/objects/$loader_filename" or die "Can't open $gen_root/objects/$loader_filename for writing. Exiting";

    #print_licence_header( C_FILE );

    print C_FILE "\n";
    print C_FILE "#include <iostream>\n";
    print C_FILE "#include <sstream>\n";
    print C_FILE "\n";
    print C_FILE "\n";
    print C_FILE "#include \"trad4.h\"\n";
    print C_FILE "#include \"$name.h\"\n";

    foreach $tuple ( @sub ) {

        ( $type, $var ) = split / /, $tuple;
        
        print C_FILE "#include \"$var.h\"\n";

    }

    print C_FILE "\n";
    print C_FILE "#include \"mysql/mysql.h\"\n";
    print C_FILE "\n";
    print C_FILE "extern void* obj_loc[NUM_OBJECTS+1];\n";
    print C_FILE "extern void* calculate_$name"."_wrapper( void* id );\n";
    print C_FILE "extern int create_shmem( void** ret_mem, size_t pub_size );\n";
    print C_FILE "extern bool $name"."_need_refresh( int id );\n";
    print C_FILE "extern int tier_manager[NUM_TIERS+1][NUM_OBJECTS+1];\n";
    print C_FILE "\n";
    print C_FILE "void load_$name( MYSQL* mysql )\n";
    print C_FILE "{\n";
    print C_FILE "    std::cout << \"load_$name"."s()\" << std::endl;\n";
    print C_FILE "\n";
    print C_FILE "    MYSQL_RES *result;\n";
    print C_FILE "    MYSQL_ROW row;\n";
    print C_FILE "\n";
    print C_FILE "    std::ostringstream dbstream;\n";
    print C_FILE "    dbstream << \"select o.id, o.name, o.log_level ";

    foreach $tuple ( @static ) {

        ( $type, $var ) = split / /, $tuple;
        
        print C_FILE ", t.$var ";

    }

    foreach $tuple ( @sub ) {

        ( $type, $var ) = split / /, $tuple;
        
        print C_FILE ", t.$var ";

    }

    print C_FILE " from object o ";

    if ( @static || @sub ) {
        print C_FILE ", $name t ";
    }

    print C_FILE " where ";

    if ( @static || @sub ) {
        print C_FILE " o.id = t.id and ";

    }
    print C_FILE " o.type = ".$types_map{$name}."\";\n";


    print C_FILE "\n";
    print C_FILE "    if(mysql_query(mysql, dbstream.str().c_str()) != 0) {\n";
    print C_FILE "        std::cout << __LINE__ << \": \" << mysql_error(mysql) << std::endl;\n";
    print C_FILE "        exit(0);\n";
    print C_FILE "    }\n";
    print C_FILE "\n";
    print C_FILE "    result = mysql_use_result(mysql);\n";
    print C_FILE "\n";

    if ( $is_feed ) {
        print C_FILE "void* tmp;\n";
    }

    print C_FILE "    while (( row = mysql_fetch_row(result) ))\n";
    print C_FILE "    {\n";
    print C_FILE "        int id = atoi(row[0]);\n";
    print C_FILE "\n";
    print C_FILE "        obj_loc[id] = new $name;\n";
    print C_FILE "\n";
    print C_FILE "        (($name*)obj_loc[id])->id = id;\n";
    print C_FILE "        (($name*)obj_loc[id])->log_level = atoi(row[2]);\n";
    print C_FILE "        (($name*)obj_loc[id])->last_published = 0;\n";
    print C_FILE "        (($name*)obj_loc[id])->status = STOPPED;\n";
    print C_FILE "        (($name*)obj_loc[id])->calculator_fpointer = &calculate_$name"."_wrapper;\n";
    print C_FILE "        (($name*)obj_loc[id])->need_refresh_fpointer = &$name"."_need_refresh;\n";
    print C_FILE "        (($name*)obj_loc[id])->type = ".$types_map{$name}.";\n";
    print C_FILE "        //(($name*)obj_loc[id])->name = 0;\n";
    print C_FILE "        \n";

    if ( $is_feed ) {

        print C_FILE "        (($name*)obj_loc[id])->shmid = create_shmem( \&tmp, sizeof( $name"."_sub ) );;\n";
        print C_FILE "        (($name*)obj_loc[id])->sub = ($name"."_sub*)tmp;\n";
        print C_FILE "        ((($name*)obj_loc[id])->sub)->last_published = 0;\n";

    }

    my $counter=3;

    foreach $tuple ( @static ) {

        ( $type, $var ) = split / /, $tuple;

        print C_FILE "        (($name*)obj_loc[id])->$var = ";

        print C_FILE type2atoX($type)."(row[$counter]);\n";

        $counter++
    }

    foreach $tuple ( @sub ) {

        ( $type, $var ) = split / /, $tuple;

        print C_FILE "        (($name*)obj_loc[id])->$var = ";

        if ( $type =~ /int/ ) {
            print C_FILE "atoi(row[$counter]);\n";
        }
        else {
            print C_FILE "atof(row[$counter]);\n";
        }
        $counter++
    }


    print C_FILE "\n";
    print C_FILE "        tier_manager[$tier][tier_manager[$tier][0]] = id;\n";
    print C_FILE "        tier_manager[$tier][0]++;\n";
    print C_FILE "\n";
    print C_FILE "        std::cout << \"New $name created.\" << std::endl;\n";

    print C_FILE "    }\n";
    print C_FILE "\n";
    print C_FILE "    mysql_free_result(result);\n";
    print C_FILE "}\n";

    close C_FILE;
}

sub generate_c_wrapper()
{
    open C_FILE, ">$gen_root/objects/$c_wrapper_filename" or die "Can't open $gen_root/objects/$c_wrapper_filename for writing. Exiting";

    #print_licence_header( C_FILE );

    print C_FILE "\n";
    print C_FILE "#include <iostream>\n";
    print C_FILE "\n";
    print C_FILE "#include \"trad4.h\"\n";
    print C_FILE "#include \"$name.h\"\n";
    print C_FILE "#include \"$name"."_macros.h\"\n";

    foreach $tuple ( @sub ) {

        ( $type, $var ) = split / /, $tuple;
        
        print C_FILE "#include \"$var.h\"\n";

    }

    print C_FILE "\n";
    print C_FILE "extern void* obj_loc[NUM_OBJECTS+1];\n";
    print C_FILE "\n";
    print C_FILE "extern void set_timestamp( int id );\n";

    print C_FILE "extern void* calculate_$name( int id );";

    print C_FILE "\n";
    print C_FILE "void* calculate_$name"."_wrapper( void* id )\n";
    print C_FILE "{\n";
    print C_FILE "\n";
    print C_FILE "    calculate_$name( (int)id );\n";
    print C_FILE "\n";
    print C_FILE "    set_timestamp((int)id);\n";
    print C_FILE "\n";
    print C_FILE "}\n";
    print C_FILE "\n";
    print C_FILE "bool ".$name."_need_refresh( int id )\n";
    print C_FILE "{\n";

    print C_FILE "    DEBUG( \"$name"."_need_refresh( \" << id << \")\" )\n";

    print C_FILE "\n";
    print C_FILE "    bool retval = (";

    if ( $is_feed ) {

        print C_FILE "(((object_header*)obj_loc[id])->status == STOPPED ) && ( *(int*)obj_loc[id] < ((($name*)obj_loc[id])->sub)->last_published ));\n";


    }
    else {

        print C_FILE "(((object_header*)obj_loc[id])->status == STOPPED ) && ( ";

        foreach $tuple ( @sub ) {

            ( $type, $var ) = split / /, $tuple;

            print C_FILE "( *(int*)obj_loc[id] < *(int*)obj_loc[(($name*)obj_loc[id])->$var] ) || ";


        }

        print C_FILE " 0 ));\n";

    }


    if ( $is_feed ) {

        print C_FILE "\n";
        print C_FILE "    DEBUG( \"\tstatus=\" << ((object_header*)obj_loc[id])->status<< \" this ts=\" <<  *(int*)obj_loc[id] << \" sub ts=\" << ((($name*)obj_loc[id])->sub)->last_published << \" retval=\" << retval )\n";
    }

    print C_FILE "\n";
    print C_FILE "    return retval;\n";
    print C_FILE "\n";
    print C_FILE "}\n";

    close C_FILE;
}

sub generate_c()
{
    open C_FILE, ">$obj_root/$c_filename" or die "Can't open $obj_root/$c_filename for writing. Exiting";

    #print_licence_header( C_FILE );

    print C_FILE "\n";
    print C_FILE "#include <iostream>\n";
    print C_FILE "\n";
    print C_FILE "#include \"$name"."_wrapper.c\"\n";
    print C_FILE "\n";
    print C_FILE "using namespace std;\n";
    print C_FILE "\n";
    print C_FILE "void* calculate_$name( int id )\n";
    print C_FILE "{\n";
    print C_FILE "    DEBUG( \"calculate_$name( \" << id << \")\" )\n";
    print C_FILE "}\n";
    print C_FILE "\n";

    close C_FILE;
}

sub generate_table() {
    
    open TABLE_FILE, ">$gen_root/sql/$table_filename" or die "Can't open $gen_root/sql/$table_filename for writing. Exiting";

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

sub type2atoX($) {
    my $type = shift;

    if ( $type =~ /int/ ) {
        return "atoi";
    }
    elsif ( $type =~ /_enum/ ) {
        return "($type)atoi";
    }
    elsif ( $type =~ /double/ ) {
        return "std::atof";
    }
    else {
        die "Odd type: $type";
    }
}

