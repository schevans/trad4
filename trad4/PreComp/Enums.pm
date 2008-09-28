# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#

package PreComp::Enums;

use Data::Dumper;
use warnings;


sub Generate($) {
    my $enum_hash = shift;

    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::GenObjRoot()."enums.h" );

    print $FHD "\n";
    print $FHD "#ifndef __enums_h__\n";
    print $FHD "#define __enums_h__\n";
    print $FHD "\n";

    foreach $key ( keys %{$enum_hash} ) {

        print $FHD "enum $key {\n";

        foreach $var ( @{$enum_hash->{$key}} ) {

            print $FHD "    $var,\n";

        }
        print $FHD "};\n";
        print $FHD "\n";
    }
    print $FHD "\n";
    print $FHD "#endif\n";

    PreComp::Utilities::CloseFile();
}


1;

