# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#

package PreComp::Structures;

use Data::Dumper;
use warnings;


sub Generate($) {
    my $struct_hash = shift;

    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::GenObjRoot()."structures.h" );
    if( ! $FHD ) { return; }

    print $FHD "\n";
    print $FHD "#ifndef __structures_h__\n";
    print $FHD "#define __structures_h__\n";
    print $FHD "\n";
    print $FHD "#include \"constants.h\"\n";
    print $FHD "#include \"aliases.h\"\n";
    print $FHD "\n";

    foreach $structure ( @{$struct_hash->{order}} ) {

        print $FHD "typedef struct {\n";

        foreach $var ( @{$struct_hash->{data}{$structure}{order}} ) {

            print $FHD "    $struct_hash->{data}{$structure}{data}{$var} $var;\n";

        }
        print $FHD "} $structure;\n";
        print $FHD "\n";
    }
    print $FHD "\n";
    print $FHD "#endif\n";

    PreComp::Utilities::CloseFile();
}


1;

