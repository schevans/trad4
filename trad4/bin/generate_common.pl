#!/usr/bin/perl

sub generate_obj_make();
sub generate_gen_obj_make();
sub generate_viewer_make();
sub generate_object_factory();
sub generate_static_data();
sub lower2camel_case($);

my $defs_root=$ENV{INSTANCE_ROOT}."/defs";
my $gen_root=$ENV{INSTANCE_ROOT}."/gen";
my $obj_root=$ENV{INSTANCE_ROOT}."/objects";

my $all_headers = "-I".$ENV{INSTANCE_ROOT}."/objects -I".$ENV{INSTANCE_ROOT}."/gen/objects -I".$ENV{TRAD4_ROOT}."/objects";

open TYPES_FILE, "$ENV{INSTANCE_ROOT}/defs/object_types.t4s" or die "Can't open $ENV{INSTANCE_ROOT}/defs/object_types.t4s for reading";

my ( $line, $num, $type );
my %types_map;
my @all_objs;

while ( $line = <TYPES_FILE> ) {

    chomp $line;
    ( $num, $type ) = split /,/, $line;
    $types_map{$type} = $num;
    push @all_objs, $type;
}

close TYPES_FILE;

system( "touch $ENV{INSTANCE_ROOT}/objects/common.h" );

generate_gen_obj_make();
#generate_viewer_make();
generate_obj_make();
generate_object_factory();
#generate_static_data();


sub generate_gen_obj_make() {

    open MAKE_FILE, ">$gen_root/objects/Makefile" or die "Can't open $gen_root/objects/Makefile";


    print MAKE_FILE "\n";
    print MAKE_FILE "CXX = g++\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "CXXFLAGS = -Wall $all_headers\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "COMPILE = \$(CXX) \$(CXXFLAGS) -c\n";
    print MAKE_FILE "\n";

    print MAKE_FILE "OBJECTS = ObjectFactory.o";

    foreach $obj (@all_objs) {

        print MAKE_FILE " ".lower2camel_case($obj)."Base.o";
    }

    print MAKE_FILE "\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "all : \$(OBJECTS)\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "%.o : %.cc\n";
    print MAKE_FILE "	\$(COMPILE) \$< -o \$@\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "clean :\n";
    print MAKE_FILE "	rm -f \$(OBJECTS)\n";
    print MAKE_FILE "\n";

    close MAKE_FILE;
}


sub generate_viewer_make() {

    open MAKE_FILE, ">$gen_root/viewer/Makefile" or die "Can't open $gen_root/viewer/Makefile";


    print MAKE_FILE "\n";
    print MAKE_FILE "CXX = g++\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "CXXFLAGS = -Wall $all_headers\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "COMPILE = \$(CXX) \$(CXXFLAGS) -c\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "OBJECTS = ";

    foreach $obj (@all_objs) {

        print MAKE_FILE " $obj";
    }

    print MAKE_FILE "\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "all : \$(OBJECTS)\n";
    print MAKE_FILE "\n";

    foreach $obj (@all_objs) {

        print MAKE_FILE "$obj: ".lower2camel_case( $obj )."Viewer.cpp\n";
        print MAKE_FILE "	gcc -o $obj ".lower2camel_case( $obj )."Viewer.cpp `pkg-config gtkmm-2.4 --libs --cflags`\n";
    print MAKE_FILE "\n";
    }

    print MAKE_FILE "\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "clean :\n";
    print MAKE_FILE "	rm -f \$(OBJECTS)\n";
    print MAKE_FILE "\n";

    close MAKE_FILE;
}

sub generate_obj_make() {

    open MAKE_FILE, ">$obj_root/Makefile" or die "Can't open $obj_root/Makefile";


    print MAKE_FILE "\n";
    print MAKE_FILE "CXX = g++\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "CXXFLAGS = -Wall $all_headers\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "COMPILE = \$(CXX) \$(CXXFLAGS) -c\n";
    print MAKE_FILE "\n";

    print MAKE_FILE "OBJECTS =";

    foreach $obj (@all_objs) {

        print MAKE_FILE " ".lower2camel_case($obj).".o";
    }

    print MAKE_FILE "\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "all : \$(OBJECTS)\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "%.o : %.cc\n";
    print MAKE_FILE "	\$(COMPILE) \$< -o \$@\n";
    print MAKE_FILE "\n";
    print MAKE_FILE "clean :\n";
    print MAKE_FILE "	rm -f \$(OBJECTS)\n";
    print MAKE_FILE "\n";

    close MAKE_FILE;

}

sub generate_object_factory() {

    open H_FILE, ">$gen_root/objects/ObjectFactory.h" or die "Can't open $gen_root/objects/ObjectFactory.h";

    print H_FILE "\n";
    print H_FILE "#ifndef __OBJECT_FACTORY_H__\n";
    print H_FILE "#define __OBJECT_FACTORY_H__\n";
    print H_FILE "\n";
    print H_FILE "#include \"Object.h\"\n";
    print H_FILE "\n";
    print H_FILE "class ObjectFactory {\n";
    print H_FILE "\n";
    print H_FILE "public:\n";
    print H_FILE "\n";
    print H_FILE "    static Object* createObject( int id, int type );\n";
    print H_FILE "\n";
    print H_FILE "private:\n";
    print H_FILE "\n";
    print H_FILE "    ObjectFactory();\n";
    print H_FILE "\n";
    print H_FILE "};\n";
    print H_FILE "\n";
    print H_FILE "#endif\n";
    print H_FILE "\n";

    close H_FILE;

    open CPP_FILE, ">$gen_root/objects/ObjectFactory.cpp" or die "Can't open $gen_root/objects/ObjectFactory.cpp";
    
    print CPP_FILE "\n";
    print CPP_FILE "#include <iostream>\n";
    print CPP_FILE "\n";
    print CPP_FILE "#include \"ObjectFactory.h\"\n";
    print CPP_FILE "\n";

    foreach $obj (@all_objs) {

        print CPP_FILE "#include \"".lower2camel_case($obj).".h\"\n";
    }



    print CPP_FILE "\n";
    print CPP_FILE "using namespace std;\n";
    print CPP_FILE "\n";
    print CPP_FILE "Object* ObjectFactory::createObject( int id, int type )\n";
    print CPP_FILE "{\n";
    print CPP_FILE "\n";
    print CPP_FILE "    Object* object;\n";
    print CPP_FILE "\n";
    print CPP_FILE "    switch ( type ) {\n";
    print CPP_FILE "\n";

    my $i;

    for ( $i = 0 ; $i < @all_objs ; $i++ ) {
    
        
        print CPP_FILE "        case ".($i+1).":\n";
        print CPP_FILE "            object = new ".lower2camel_case( $all_objs[$i] )."( id );\n";
        print CPP_FILE "            break;\n";

    } 

    print CPP_FILE "        default:\n";
    print CPP_FILE "               cout << \"Unknown type \" << type << \". Doing nothing\" << endl;\n";
    print CPP_FILE "\n";
    print CPP_FILE "    }\n";
    print CPP_FILE "\n";
    print CPP_FILE "    return object;\n";
    print CPP_FILE "\n";
    print CPP_FILE "}\n";
    print CPP_FILE "\n";

    close CPP_FILE;
}

sub generate_static_data() {

    open OBJ_TYPE_FILE, ">$gen_root/sql/object_type.sql" or die "Can't open $gen_root/sql/object_type.table";

    print OBJ_TYPE_FILE "delete from object_type;\n";

    my $i;

    my @objs = ( @all_objs, @feed_objs );

    for ( $i = 0 ; $i < @objs ; $i++ ) {
    
        print OBJ_TYPE_FILE "insert into object_type values ( ".($i+1).", \"$objs[$i]\" );\n";

    } 
    
    close OBJ_TYPE_FILE;
}

sub lower2camel_case($) {
    my $lower_case = shift;

    my $camel_case = $lower_case;
    $camel_case =~ s/_/ /g;
    $camel_case =~ s/([A-Za-z])([A-Za-z]+)/\U$1\E\L$2\E/g;
    $camel_case =~ s/ //g;

    return $camel_case;
}

