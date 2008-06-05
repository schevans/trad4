
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

    my $FHD = PreComp::Utilities::OpenFile( "$ENV{INSTANCE_ROOT}/Makefile" );

    #print_licence_header( $FHD );

    print $FHD "\n";
    print $FHD "CXX = g++\n";
    print $FHD "\n";
    print $FHD "CXXFLAGS = $all_headers\n";
    print $FHD "\n";
    print $FHD "COMPILE = \$(CXX) \$(CXXFLAGS) -c\n";
    print $FHD "\n";
    print $FHD "\n";
    print $FHD "SUBDIRS = \$(INSTANCE_ROOT)/objects \$(INSTANCE_ROOT)/lib \$(TRAD4_ROOT)/objects\n";
    print $FHD "\n";


    print $FHD "all: objs bond_risk\n";
    print $FHD "\n";
    print $FHD "bond_risk: objects/main.o\n";
    print $FHD "	g++ objects/main.o \$(TRAD4_ROOT)/libs/sqlite3.o -o bin/bond_risk -ltrad4 -L\$(TRAD4_ROOT)/objects -lpthread -ldl\n";
    print $FHD "\n";
    print $FHD "objs:\n";

    print $FHD "	for dir in \$(SUBDIRS); do cd \$\$dir; \$(MAKE) all ; cd \$(INSTANCE_ROOT); done\n";
    print $FHD "\n";


    print $FHD "\n";
    print $FHD "clean: clean_objs clean_$ENV{INSTANCE}\n";
    print $FHD "\n";
    print $FHD "clean_objs:\n";
    print $FHD "	for dir in \$(SUBDIRS); do cd \$\$dir; \$(MAKE) clean; cd \$(INSTANCE_ROOT); done\n";
    print $FHD "\n";
    print $FHD "clean_$ENV{INSTANCE}:\n";
    print $FHD "	rm -f bin/$ENV{INSTANCE}\n";
    print $FHD "\n";

    PreComp::Utilities::CloseFile();
}

sub generate_object_make($) {
    my $obj_hash = shift;

    my $FHD = PreComp::Utilities::OpenFile( "$ENV{INSTANCE_ROOT}/objects/Makefile" );

    #print_licence_header( $FHD );

    print $FHD "\n";
    print $FHD "CXX = g++\n";
    print $FHD "\n";
    print $FHD "CXXFLAGS = -Wall -c\n";
    print $FHD "\n";
    print $FHD "COMPILE = \$(CXX) \$(CXXFLAGS)\n";
    print $FHD "\n";

    print $FHD "all: main.o";

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
        print $FHD "	\$(COMPILE) -I\$(INSTANCE_ROOT)/objects -I\$(INSTANCE_ROOT)/gen/objects -I\$(TRAD4_ROOT)/objects -c $type.c -o $type.o\n";
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

    my $FHD = PreComp::Utilities::OpenFile( "$ENV{INSTANCE_ROOT}/lib/Makefile" );

    #print_licence_header( $FHD );
          
    print $FHD "\n";
    print $FHD "CXX = g++\n";
    print $FHD "\n";
    print $FHD "CXXFLAGS = $all_headers\n";
    print $FHD "\n";
    print $FHD "COMPILE = \$(CXX) \$(CXXFLAGS) -c\n";
    print $FHD "\n";

    print $FHD "LIBS =";

    foreach $type ( keys %{$obj_hash} ) {

        $name = $obj_hash->{$type}->{name};

        print $FHD " lib$name.so";
    }

    print $FHD "\n";
    print $FHD "\n";
    print $FHD "all: \$(LIBS)\n";
    print $FHD "\n";


    foreach $type ( keys %{$obj_hash} ) {

        $name = $obj_hash->{$type}->{name};

        print $FHD "lib$name.so: ../objects/$type.c ../gen/objects/$type"."_wrapper.c\n";
        print $FHD "	g++ -shared -Wl,-soname,lib$name.so -o lib$name.so ../../sqlite-amalgamation-3.5.9/sqlite3.o ../objects/$type.o\n";
        print $FHD "\n";
    
    }

    print $FHD "\n";
    print $FHD "clean:\n";
    print $FHD "	rm -f \$(LIBS)\n";
    print $FHD "\n";

    PreComp::Utilities::CloseFile();
}

1;

