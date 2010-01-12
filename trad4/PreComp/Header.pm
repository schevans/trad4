# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#

package PreComp::Header;

use PreComp::Utilities;
use PreComp::Constants;
use Data::Dumper;

sub Generate($) {
    my $obj_hash = shift;

    my $name = $obj_hash->{name};

    my @header = PreComp::Constants::CommomHeader();

    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::GenObjRoot().$name.".".h );
    if( ! $FHD ) { return; }

    print $FHD "\n";
    print $FHD "#ifndef __$name"."__\n";
    print $FHD "#define __$name"."__\n";
    print $FHD "\n";
    print $FHD "#include <sys/types.h>\n";
    print $FHD "\n";
    print $FHD "#include \"structures.h\"\n";
    print $FHD "#include \"enums.h\"\n";
    print $FHD "#include \"constants.h\"\n";
    print $FHD "#include \"aliases.h\"\n";
    print $FHD "\n";
    print $FHD "namespace t4 {\n";
    print $FHD "\n";

    print $FHD "    typedef struct {\n";

    print $FHD "        // header\n";

    foreach $tuple ( @header ) {

        ( $type, $var ) = split / /, $tuple;

        print $FHD "        $type $var;\n";

    }

    foreach $section ( "sub", "sub_vec", "static", "static_vec", "pub", "pub_vec" ) {

        if ( $section !~ /\_vec/ ) {

            print $FHD "\n        // $section\n";
        }

        PreComp::Utilities::PrintHeader( $FHD, $obj_hash, $section );
    }

    print $FHD "    } $name;\n";
    print $FHD "\n";
    print $FHD "}\n";
    print $FHD "\n";
    print $FHD "#endif\n";

    PreComp::Utilities::CloseFile();
}

1;

