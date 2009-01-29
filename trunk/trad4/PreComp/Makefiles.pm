# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#

package PreComp::Makefiles;

use PreComp::Utilities;
use PreComp::Constants;
use Data::Dumper;

sub generate_lib_make($);
sub generate_object_make($);
sub generate_top_lvl_make($);


sub Generate($) {
    my $obj_hash = shift;

    generate_lib_make( $obj_hash );

    generate_object_make( $obj_hash );

    generate_top_lvl_make( $obj_hash );

}

sub generate_top_lvl_make($) {
    my $obj_hash = shift;

    my $FHD = PreComp::Utilities::OpenFile( "$ENV{APP_ROOT}/Makefile" );

    print $FHD "\n";
    print $FHD "CXX = g++ -m32\n";
    print $FHD "\n";
    print $FHD "CXXFLAGS = $all_headers\n";
    print $FHD "\n";
    print $FHD "COMPILE = \$(CXX) \$(CXXFLAGS) -c\n";
    print $FHD "\n";
    print $FHD "\n";
    print $FHD "SUBDIRS = \$(TRAD4_ROOT)/objects \$(APP_ROOT)/objects \$(APP_ROOT)/lib\n";
    print $FHD "\n";


    print $FHD "all: objs $ENV{APP}\n";
    print $FHD "\n";
    print $FHD "$ENV{APP}: objects/main.o\n";
    print $FHD "	g++ -m32 objects/main.o \$(TRAD4_ROOT)/objects/sqlite3.o -o bin/$ENV{APP} -ltrad4 -L\$(TRAD4_ROOT)/objects -lpthread -ldl -L\$(APP_ROOT)/lib\n";
    print $FHD "\n";
    print $FHD "objs:\n";

    print $FHD "	for dir in \$(SUBDIRS); do cd \$\$dir; \$(MAKE) all ; cd \$(APP_ROOT); done\n";
    print $FHD "\n";


    print $FHD "\n";
    print $FHD "clean: clean_objs clean_$ENV{APP}\n";
    print $FHD "\n";
    print $FHD "clean_objs:\n";
    print $FHD "	for dir in \$(SUBDIRS); do cd \$\$dir; \$(MAKE) clean; cd \$(APP_ROOT); done\n";
    print $FHD "\n";
    print $FHD "clean_$ENV{APP}:\n";
    print $FHD "	rm -f bin/$ENV{APP}\n";
    print $FHD "\n";

    PreComp::Utilities::CloseFile();
}

sub generate_object_make($) {
    my $obj_hash = shift;

    my $FHD = PreComp::Utilities::OpenFile( "$ENV{APP_ROOT}/objects/Makefile" );

    print $FHD "\n";
    print $FHD "CXX = g++ -m32\n";
    print $FHD "\n";
    print $FHD "CXXFLAGS =  -Wall -c\n";
    print $FHD "\n";
    print $FHD "COMPILE = \$(CXX) \$(CXXFLAGS)\n";
    print $FHD "\n";

    print $FHD "all: main.o ";

    foreach $type ( keys %{$obj_hash} ) {

        print $FHD " $type.o";
    }

    print $FHD "\n";
    print $FHD "\n";
    print $FHD "main.o: main.c\n";
    print $FHD "	\$(COMPILE) main.c -I\$(TRAD4_ROOT)/objects\n";
    print $FHD "\n";

    foreach $type ( keys %{$obj_hash} ) {

        print $FHD "$type.o: $type.c ../gen/objects/$type"."_wrapper.c\n";
        print $FHD "	\$(COMPILE) -I\$(APP_ROOT)/objects -I\$(APP_ROOT)/gen/objects -I\$(TRAD4_ROOT)/objects -c $type.c -o $type.o\n";
        print $FHD "\n";
    }

    print $FHD "\n";
    print $FHD "clean:\n";
    print $FHD "	rm -f *.o\n";
    print $FHD "\n";

    PreComp::Utilities::CloseFile();
}


sub generate_lib_make($) {
    my $obj_hash = shift;

    my $FHD = PreComp::Utilities::OpenFile( "$ENV{APP_ROOT}/lib/Makefile" );

    print $FHD "\n";
    print $FHD "CXX = g++ -m32\n";
    print $FHD "\n";
    print $FHD "CXXFLAGS = $all_headers\n";
    print $FHD "\n";
    print $FHD "COMPILE = \$(CXX) \$(CXXFLAGS) -c \n";
    print $FHD "\n";

    print $FHD "LIBS =";

    foreach $type ( keys %{$obj_hash} ) {

        $name = $obj_hash->{$type}->{name};

        print $FHD " lib$name.so";
    }

    print $FHD "\n";
    print $FHD "all: \$(LIBS)\n";
    print $FHD "\n";


    foreach $type ( keys %{$obj_hash} ) {

        $name = $obj_hash->{$type}->{name};

        print $FHD "lib$name.so: ../objects/$type.c ../gen/objects/$type"."_wrapper.c\n";
        print $FHD "	g++ -m32 -shared -Wl,-soname,lib$name.so -o lib$name.so \$(TRAD4_ROOT)/objects/sqlite3.o ../objects/$type.o\n";
        print $FHD "\n";
    
    }

    print $FHD "\n";
    print $FHD "clean:\n";
    print $FHD "	rm -f \$(LIBS)\n";
    print $FHD "\n";

    PreComp::Utilities::CloseFile();
}

1;

