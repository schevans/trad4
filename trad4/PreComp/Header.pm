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

    print $FHD "\n";
    print $FHD "#ifndef __$name"."__\n";
    print $FHD "#define __$name"."__\n";
    print $FHD "\n";
    print $FHD "#include <sys/types.h>\n";
    print $FHD "\n";
    print $FHD "#include \"common.h\"\n";
    print $FHD "#include \"structures.h\"\n";
    print $FHD "#include \"enums.h\"\n";
    print $FHD "\n";

    if ( PreComp::Utilities::HasFeed( $obj_hash ) ) {

        print $FHD "typedef struct {\n";

        PreComp::Utilities::PrintSection( $FHD, $obj_hash->{data}->{feed_in}, "    " );
        PreComp::Utilities::PrintSection( $FHD, $obj_hash->{data}->{feed_out}, "    " );

        print $FHD "    int last_published;\n";
        print $FHD "} $name"."_$has_feed;\n";
        print $FHD "\n";

    }

    print $FHD "typedef struct {\n";

    print $FHD "    // Header\n";

    foreach $tuple ( @header ) {

        ( $type, $var ) = split / /, $tuple;

        print $FHD "    $type $var;\n";

    }


    print $FHD "\n";
    print $FHD "    // Sub\n";

    PreComp::Utilities::PrintSection( $FHD, $obj_hash->{data}->{sub}, "    " );

    print $FHD "\n";
    print $FHD "    // Feed\n";

    if ( PreComp::Utilities::HasFeed( $obj_hash ) ) {

        print $FHD "    int shmid;\n";
        print $FHD "    $name"."_$has_feed* $has_feed;\n";
    }

    print $FHD "\n";
    print $FHD "    // Static\n";

    PreComp::Utilities::PrintSection( $FHD, $obj_hash->{data}->{static}, "    " );
    PreComp::Utilities::PrintSection( $FHD, $obj_hash->{data}->{static_vec}, "    " );
    PreComp::Utilities::PrintSection( $FHD, $obj_hash->{data}->{feed_in}, "    " );

    print $FHD "\n";
    print $FHD "    // Pub\n";

    PreComp::Utilities::PrintSection( $FHD, $obj_hash->{data}->{pub}, "    " );
    PreComp::Utilities::PrintSection( $FHD, $obj_hash->{data}->{pub_vec}, "    " );
    PreComp::Utilities::PrintSection( $FHD, $obj_hash->{data}->{mem_pub}, "    " );
    PreComp::Utilities::PrintSection( $FHD, $obj_hash->{data}->{feed_in}, "    " );

    print $FHD "} $name;\n";
    print $FHD "\n";
    print $FHD "#endif\n";

    PreComp::Utilities::CloseFile();
}

1;

