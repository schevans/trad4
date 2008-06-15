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
    print $FHD "#include <iostream>\n";
    print $FHD "\n";
    print $FHD "#include \"$name"."_wrapper.c\"\n";
    print $FHD "\n";
    print $FHD "using namespace std;\n";
    print $FHD "\n";
    print $FHD "void calculate_$name( obj_loc_t obj_loc, int id )\n";
    print $FHD "{\n";
    print $FHD "    DEBUG( \"calculate_$name( \" << id << \")\" )\n";
    print $FHD "}\n";
    print $FHD "\n";

    if ( %{$obj_hash->{data}->{static_vec}} ) {

        print $FHD "\n";
        print $FHD "void extra_loader( obj_loc_t obj_loc, int id, sqlite3* db )\n";
        print $FHD "{\n";
        print $FHD "    cout << \"extra_loader()\" << endl;\n";
        print $FHD "\n";
        print $FHD "}\n";
    }

    PreComp::Utilities::CloseFile();
}

1;
