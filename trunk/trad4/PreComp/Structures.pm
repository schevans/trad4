# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#

package PreComp::Structures;

use Data::Dumper;
use warnings;


sub Generate($) {
    my $struct_hash = shift;



    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::GenObjRoot()."structures.h" );

    print $FHD "\n";
    print $FHD "#ifndef __structures_h__\n";
    print $FHD "#define __structures_h__\n";
    print $FHD "\n";

    foreach $key ( keys %{$struct_hash} ) {

        print $FHD "typedef struct {\n";

        foreach $var ( keys %{$struct_hash->{$key}} ) {

            print $FHD "    $struct_hash->{$key}->{$var} $var;\n";

        }
        print $FHD "} $key;\n";
        print $FHD "\n";
    }
    print $FHD "\n";
    print $FHD "#endif\n";




    PreComp::Utilities::CloseFile();
}


1;
