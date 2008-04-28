
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


    print $FHD "all: objs $ENV{INSTANCE}\n";
    print $FHD "\n";
    print $FHD "\n";
    print $FHD "objs: \n";

    print $FHD "	for dir in \$(SUBDIRS); do cd \$\$dir; \$(MAKE) all ; cd \$(INSTANCE_ROOT); done\n";
    print $FHD "\n";


    print $FHD "\n";
    print $FHD "clean: clean_objs clean_$ENV{INSTANCE}\n";
    print $FHD "\n";
    print $FHD "clean_objs:\n";
    print $FHD "	for dir in \$(SUBDIRS); do cd \$\$dir; \$(MAKE) clean; cd \$(INSTANCE_ROOT); done\n";
    print $FHD "\n";
    print $FHD "clean_$ENV{INSTANCE}:\n";
    print $FHD "	rm -f $ENV{INSTANCE}\n";
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
    print $FHD "CXXFLAGS = $all_headers\n";
    print $FHD "\n";
    print $FHD "COMPILE = \$(CXX) \$(CXXFLAGS) -c\n";
    print $FHD "\n";

    print $FHD "all:";

    foreach $type ( keys %{$obj_hash} ) {

        print $FHD " $type.o";
    }

    print $FHD "\n";
    print $FHD "\n";

    foreach $type ( keys %{$obj_hash} ) {

        print $FHD "$type.o: $type.c ../gen/objects/$type"."_wrapper.c\n";
        print $FHD "	g++ -I/home/steve/src/black_scholes/objects -I/home/steve/src/black_scholes/gen/objects -I/home/steve/src/trad4/objects -c $type.c -o $type.o\n";
        print $FHD "\n";
    }

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

        $type_num = $obj_hash->{$type}->{type_num};

        print $FHD " t4lib_$type_num";
    }

    print $FHD "\n";
    print $FHD "\n";
    print $FHD "all: \$(LIBS)\n";
    print $FHD "\n";


    foreach $type ( keys %{$obj_hash} ) {

        $type_num = $obj_hash->{$type}->{type_num};

        print $FHD "t4lib_$type_num: ../objects/$type.c ../gen/objects/$type"."_wrapper.c\n";
        print $FHD "	g++ -shared -Wl,-soname,t4lib_$type_num -o t4lib_$type_num ../objects/$type.o -L/usr/local/lib/mysql -lmysqlclient\n";
        print $FHD "\n";
    
    }

    print $FHD "\n";
    print $FHD "\n";

    PreComp::Utilities::CloseFile();
}

1;

