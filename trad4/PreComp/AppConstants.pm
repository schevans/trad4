# Copyright (c) Steve Evans 2008
# schevans@users.sourceforge.net
#

package PreComp::AppConstants;

use Data::Dumper;
use warnings;


sub Generate($) {
    my $constants_hash = shift;

    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::GenObjRoot()."constants.h" );
    if( ! $FHD ) { return; }

    print $FHD "\n";
    print $FHD "#ifndef __t4_app_constants_h__\n";
    print $FHD "#define __t4_app_constants_h__\n";
    print $FHD "\n";

    foreach $key ( keys %{$constants_hash} ) {

        print $FHD "#define $key $constants_hash->{$key}\n";

    }
    print $FHD "\n";
    print $FHD "#endif\n";

    PreComp::Utilities::CloseFile();
}


1;

