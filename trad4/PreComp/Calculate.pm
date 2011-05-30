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

    my $FHD = PreComp::Utilities::OpenObjectFile( PreComp::Constants::ObjRoot()."$name.c" );
    if( ! $FHD ) { return; }

    print $FHD "\n";
    print $FHD "// Please see the comment at the top of $ENV{APP}/gen/objects/$name"."_macros.h\n";
    print $FHD "//  to see what's in-scope.\n";
    print $FHD "\n";
    print $FHD "#include <iostream>\n";
    print $FHD "\n";
    print $FHD "#include \"$name"."_wrapper.c\"\n";
    print $FHD "\n";
    print $FHD "using namespace std;\n";
    print $FHD "\n";
    print $FHD "int calculate_$name( obj_loc_t obj_loc, int id )\n";
    print $FHD "{\n";
    print $FHD "    // Write me.\n";
    print $FHD "\n";
    print $FHD "    return 1;\n";
    print $FHD "}\n";
    print $FHD "\n";

    PreComp::Utilities::CloseFile();
}

1;
