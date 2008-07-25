# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#


package PreComp::Calculate;

use PreComp::Utilities;
use PreComp::Constants;
use Data::Dumper;

sub Generate($) {
    my $obj_hash = shift;

    my $name = $obj_hash->{name};

    my @header = PreComp::Constants::CommomHeader();

    my $file = PreComp::Constants::ObjRoot()."$name.c";

    if ( -f $file ) {
       return;
    } 

    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::ObjRoot()."$name.c" );

    #print_licence_header( $FHD );

    print $FHD "\n";
    print $FHD "// Please see the comment at the top of $ENV{APP}/gen/objects/$name"."_macros.c\n";
    print $FHD "//  to see what's in-scope.\n";
    print $FHD "\n";
    print $FHD "#include <iostream>\n";
    print $FHD "\n";
    print $FHD "#include \"$name"."_wrapper.c\"\n";
    print $FHD "\n";
    print $FHD "using namespace std;\n";
    print $FHD "\n";
    print $FHD "void calculate_$name( obj_loc_t obj_loc, int id )\n";
    print $FHD "{\n";
    print $FHD "    DEBUG( \"calculate_$name( \" << id << \" )\" )\n";
    print $FHD "}\n";
    print $FHD "\n";

    if ( %{$obj_hash->{data}->{static_vec}} ) {

        print $FHD "\n";
        print $FHD "static int $name"."_extra_loader_callback(void *obj_loc_v, int argc, char **row, char **azColName)\n";
        print $FHD "{\n";
        print $FHD "/*\n";
        print $FHD "    // Have to cast to unsigned char** here as C++ doesn't like\n";
        print $FHD "    //  void* arithmetic for some strange reason...\n";
        print $FHD "    unsigned char** obj_loc = (unsigned char**)obj_loc_v;\n";
        print $FHD "\n";
        print $FHD "    int id = atoi(row[0]);\n";
        print $FHD "*/\n";
        print $FHD "}\n";
        print $FHD "\n";
        print $FHD "void $name"."_extra_loader( obj_loc_t obj_loc, int id, sqlite3* db )\n";
        print $FHD "{\n";
        print $FHD "    cout << \"$name"."_extra_loader()\" << endl;\n";
        print $FHD "\n";
        print $FHD "}\n";
    }

    PreComp::Utilities::CloseFile();
}

1;
