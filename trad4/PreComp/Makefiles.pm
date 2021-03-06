# Copyright (c) Steve Evans 2008
# schevans@users.sourceforge.net
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
    if( ! $FHD ) { return; }

    print $FHD "\n";
    print $FHD "COMPILE = \$(CXX) \$(CXXFLAGS) \n";
    print $FHD "\n";
    print $FHD "SUBDIRS = \$(TRAD4_ROOT)/objects \$(APP_ROOT)/objects \$(APP_ROOT)/lib\n";
    print $FHD "\n";


    print $FHD "all: objs $ENV{APP}\n";
    print $FHD "\n";
    print $FHD "$ENV{APP}: objects/main.o\n";
    print $FHD "	\$(COMPILE) objects/main.o \$(TRAD4_ROOT)/objects/sqlite3.o -o bin/$ENV{APP} -ltrad4 -L\$(TRAD4_ROOT)/objects -lpthread -ldl -L\$(APP_ROOT)/lib \$(T4_3RD_PARTY_LIBS)\n";
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
    if( ! $FHD ) { return; }

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
    print $FHD "	\$(COMPILE) -c main.c -I\$(TRAD4_ROOT)/objects\n";
    print $FHD "\n";

    foreach $type ( keys %{$obj_hash} ) {

        print $FHD "$type.o: $type.c ../gen/objects/$type"."_wrapper.c\n";
        print $FHD "	\$(COMPILE) -c -I\$(APP_ROOT)/objects -I\$(APP_ROOT)/gen/objects -I\$(TRAD4_ROOT)/objects";
        if ( $ENV{T4_3RD_PARTY_HEADER_PATH} ) {

            print $FHD " -I\$(T4_3RD_PARTY_HEADER_PATH)";
        }

        print $FHD " $type.c -o $type.o\n";
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
    if( ! $FHD ) { return; }

    print $FHD "\n";
    print $FHD "COMPILE = \$(CXX) \$(CXXFLAGS) \n";
    print $FHD "\n";

    print $FHD "LIBS =";

    foreach $type ( keys %{$obj_hash} ) {

        $name = $obj_hash->{$type}->{name};

        print $FHD " libt4$name.so";
    }

    print $FHD "\n";
    print $FHD "all: \$(LIBS)\n";
    print $FHD "\n";


    foreach $type ( keys %{$obj_hash} ) {

        $name = $obj_hash->{$type}->{name};

        print $FHD "libt4$name.so: ../objects/$type.c ../gen/objects/$type"."_wrapper.c\n";
        print $FHD "	\$(COMPILE) -shared -o libt4$name.so \$(TRAD4_ROOT)/objects/sqlite3.o ../objects/$type.o \$(T4_3RD_PARTY_AR)\n";
        print $FHD "\n";
    
    }

    print $FHD "\n";
    print $FHD "clean:\n";
    print $FHD "	rm -f *.so\n";
    print $FHD "\n";

    PreComp::Utilities::CloseFile();
}

1;

