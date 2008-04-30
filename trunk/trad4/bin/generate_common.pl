#!/usr/bin/perl

# Copyright (c) Steve Evans 2007
# steve@topaz.myzen.co.uk
# This code is licenced under the LGPL. For details see $TRAD4_ROOT/LICENCE

sub generate_obj_make();
sub generate_loader();
sub generate_gen_obj_make();
sub generate_top_lvl_make();
sub lower2camel_case($);
sub print_licence_header($$);

my $defs_root=$ENV{INSTANCE_ROOT}."/defs";
my $gen_root=$ENV{INSTANCE_ROOT}."/gen";
my $obj_root=$ENV{INSTANCE_ROOT}."/objects";

my $all_headers = "-I\$(INSTANCE_ROOT)/objects -I\$(INSTANCE_ROOT)/gen/objects -I\$(TRAD4_ROOT)/objects";

open TYPES_FILE, "$ENV{INSTANCE_ROOT}/defs/object_types.t4s" or die "Can't open $ENV{INSTANCE_ROOT}/defs/object_types.t4s for reading";

my ( $line, $num, $type, $tier );
my %types_map;
my @all_objs;
my %obj_type_num_map;
my $max_tier;

######################### New stuff #########################

use PreComp::Makefiles;
use PreComp::Macros;
use PreComp::Utilities;

my $master_hash = PreComp::Utilities::LoadDefs();

PreComp::Makefiles::Generate( $master_hash );
PreComp::Macros::Generate( $master_hash );

#############################################################

while ( $line = <TYPES_FILE> ) {

    chomp $line;

    if ( !$line or $line =~ /#/ ) {
        next;
    }

    ( $num, $tier, $type ) = split /,/, $line;
    $types_map{$type} = $num;
    push @all_objs, $type;

    %obj_type_num_map->{$type} = $num;

    if ( $tier > $max_tier )
    {
        $max_tier = $tier;
    }
}

close TYPES_FILE;

if ( ! -f "$ENV{INSTANCE_ROOT}/objects/common.h" ) {

    open FILE, ">$ENV{INSTANCE_ROOT}/objects/common.h" or die "Can't open $ENV{INSTANCE_ROOT}/objects/common.h";

    print FILE "#ifndef __common_h__\n";
    print FILE "#define __common_h__\n";
    print FILE "\n";
    print FILE "\n";
    print FILE "\n";
    print FILE "#endif\n";

}

#generate_gen_obj_make();
#generate_top_lvl_make();
#generate_obj_make();
#generate_loader();



sub generate_top_lvl_make() {

    open MAKE_FILE, ">$ENV{INSTANCE_ROOT}/Makefile" or die "Can't open $ENV{INSTANCE_ROOT}/Makefile";

    #print_licence_header( MAKE_FILE, "#" );

    print MAKE_FILE "\n";
    print MAKE_FILE "CXX = g++\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "CXXFLAGS = $all_headers\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "COMPILE = \$(CXX) \$(CXXFLAGS) -c\n";
    print MAKE_FILE "\n";

    print MAKE_FILE "OBJECTS = $ENV{TRAD4_ROOT}/objects/trad4.o $ENV{TRAD4_ROOT}/objects/feed.o \$(INSTANCE_ROOT)/objects/loader.o";

    foreach $obj (@all_objs) {
        print MAKE_FILE " ./objects/$obj.o";
    }

    foreach $obj (@all_objs) {
        print MAKE_FILE " ./gen/objects/load_".$obj.".o";
    }


    print MAKE_FILE "\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "SUBDIRS = \$(INSTANCE_ROOT)/objects \$(TRAD4_ROOT)/objects \$(INSTANCE_ROOT)/gen/objects\n";
    print MAKE_FILE "\n";


    print MAKE_FILE "all: objs $ENV{INSTANCE}\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "objs: \n";

    print MAKE_FILE "	for dir in \$(SUBDIRS); do cd \$\$dir; \$(MAKE) all ; cd \$(INSTANCE_ROOT); done\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "$ENV{INSTANCE}: \$(OBJECTS)\n";
    print MAKE_FILE "	\$(CXX) -o $ENV{INSTANCE} \$(OBJECTS) -lpthread -L/usr/local/lib/mysql -lmysqlclient\n";


    print MAKE_FILE "\n";
    print MAKE_FILE "clean: clean_objs clean_$ENV{INSTANCE}\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "clean_objs:\n";
    print MAKE_FILE "	for dir in \$(SUBDIRS); do cd \$\$dir; \$(MAKE) clean; cd \$(INSTANCE_ROOT); done\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "clean_$ENV{INSTANCE}:\n";
    print MAKE_FILE "	rm -f $ENV{INSTANCE}\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "opt:\n";
    print MAKE_FILE "	g++ -O3 -o $ENV{INSTANCE} ";

    print MAKE_FILE " $ENV{TRAD4_ROOT}/objects/trad4.c $ENV{TRAD4_ROOT}/objects/feed.c \$(INSTANCE_ROOT)/objects/loader.c";

    foreach $obj (@all_objs) {
        print MAKE_FILE " ./objects/$obj.c";
    }

    foreach $obj (@all_objs) {
        print MAKE_FILE " ./gen/objects/load_".$obj.".c";
    }

    print MAKE_FILE " -I./objects -I../trad4/objects -I./gen/objects -lpthread -L/usr/local/lib/mysql -lmysqlclient\n";

    print MAKE_FILE "\n";

    close MAKE_FILE;

}

sub generate_gen_obj_make() {

    open MAKE_FILE, ">$gen_root/objects/Makefile" or die "Can't open $gen_root/objects/Makefile";

    print_licence_header( MAKE_FILE, "#" );

    print MAKE_FILE "\n";
    print MAKE_FILE "CXX = g++\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "CXXFLAGS = $all_headers\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "COMPILE = \$(CXX) \$(CXXFLAGS) -c\n";
    print MAKE_FILE "\n";

    print MAKE_FILE "OBJECTS =";

    foreach $obj (@all_objs) {

        print MAKE_FILE " load_".$obj.".o";
    }

    print MAKE_FILE "\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "all : \$(OBJECTS)\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "%.o : %.c\n";
    print MAKE_FILE "	\$(COMPILE) \$< -o \$@\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "clean :\n";
    print MAKE_FILE "	rm -f \$(OBJECTS)\n";
    print MAKE_FILE "\n";

    close MAKE_FILE;
}


sub generate_loader() {

    open FILE, ">$obj_root/loader.c" or die "Can't open $obj_root/loader.c";
    
    #print_licence_header( FILE, "#" );

    print FILE "\n";
    print FILE "#include <iostream>\n";
    print FILE "#include <sstream>\n";
    print FILE "#include <vector>\n";
    print FILE "\n";
    print FILE "#include \"trad4.h\"\n";
    print FILE "#include \"common.h\"\n";
        
    foreach $obj (@all_objs) {

        print FILE "#include \"$obj.h\"\n";
    }
 

    print FILE "\n";
    print FILE "#include \"mysql/mysql.h\"\n";
    print FILE "\n";
    print FILE "MYSQL mysql;\n";
    print FILE "MYSQL_RES *result;\n";
    print FILE "MYSQL_ROW row;\n";
    print FILE "\n";
    print FILE "extern void* obj_loc[NUM_OBJECTS+1];\n";
    print FILE "\n";

    foreach $obj (@all_objs) {

        print FILE "extern void load_$obj( MYSQL* mysql );\n";
    }
 
    print FILE "\n";
    print FILE "extern int tier_manager[NUM_TIERS+1][NUM_OBJECTS+1];\n";
    print FILE "\n";
    print FILE "using namespace std;\n";
    print FILE "\n";
    print FILE "void load_all()\n";
    print FILE "{\n";
    print FILE "    mysql_init(&mysql);\n";
    print FILE "\n";
    print FILE "    if (!mysql_real_connect(&mysql,\"localhost\", \"root\", NULL,\"$ENV{INSTANCE}\",0,NULL,0))\n";
    print FILE "    {\n";
    print FILE "        std::cout << __LINE__ << \" \"  << mysql_error(&mysql) << std::endl;\n";
    print FILE "    }\n";
    print FILE "\n";

    for ( $i=1 ; $i <= $max_tier ; $i++ )
    {
        print FILE "    tier_manager[$i][0]=1;\n";
    } 

    print FILE "\n";

    foreach $obj (@all_objs) {

        print FILE "    load_$obj( &mysql );\n";

    }
    print FILE "\n";
    print FILE "}\n";

    print FILE "void reload_objects()\n";
    print FILE "{\n";

    print FILE "\n";

    foreach $obj (@all_objs) {

        print FILE "   load_$obj( &mysql );\n";

    }

    print FILE "}\n";

    close FILE;

}

sub generate_obj_make() {

    open MAKE_FILE, ">$obj_root/Makefile" or die "Can't open $obj_root/Makefile";
    
    #print_licence_header( MAKE_FILE, "#" );

    print MAKE_FILE "\n";
    print MAKE_FILE "CXX = g++\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "CXXFLAGS = $all_headers\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "COMPILE = \$(CXX) \$(CXXFLAGS) -c\n";
    print MAKE_FILE "\n";

    print MAKE_FILE "OBJECTS = loader.o";

    foreach $obj (@all_objs) {

        print MAKE_FILE " $obj.o";
    }

    print MAKE_FILE "\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "all : \$(OBJECTS)\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "%.o : %.c\n";
    print MAKE_FILE "	\$(COMPILE) \$< -o \$@\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "clean :\n";
    print MAKE_FILE "	rm -f \$(OBJECTS)\n";
    print MAKE_FILE "\n";

    close MAKE_FILE;

}

sub lower2camel_case($) {
    my $lower_case = shift;

    my $camel_case = $lower_case;
    $camel_case =~ s/_/ /g;
    $camel_case =~ s/([A-Za-z])([A-Za-z]+)/\U$1\E\L$2\E/g;
    $camel_case =~ s/ //g;

    return $camel_case;
}

sub print_licence_header($$) {
    my $FILE = shift;
    my $comment_delimeter = shift;
    open LICENCE_FILE, "$ENV{INSTANCE_ROOT}/LICENCE_HEADER" or die "Can't open $ENV{INSTANCE_ROOT}/LICENCE_HEADER.";

    my $line;
    while ( $line = <LICENCE_FILE> ) {
        print $FILE "$comment_delimeter $line";
    }

    close LICENCE_FILE;
}

