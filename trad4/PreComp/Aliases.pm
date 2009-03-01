# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#

package PreComp::Aliases;

use Data::Dumper;
use warnings;


sub Generate($) {
    my $alias_hash = shift;

    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::GenObjRoot()."aliases.h" );

    print $FHD "\n";
    print $FHD "#ifndef __aliases_h__\n";
    print $FHD "#define __aliases_h__\n";
    print $FHD "\n";

    foreach $key ( keys %{$alias_hash} ) {

        print $FHD "typedef $alias_hash->{$key} $key;\n";

    }
    print $FHD "\n";
    print $FHD "#endif\n";

    PreComp::Utilities::CloseFile();
}


1;

