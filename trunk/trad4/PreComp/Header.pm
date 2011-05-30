# Copyright (c) Steve Evans 2008
# schevans@users.sourceforge.net
#

use warnings;
use strict;

package PreComp::Header;

use PreComp::Utilities;
use PreComp::Constants;
use Data::Dumper;

sub Generate($$) {
    my $master_hash = shift;
    my $type = shift;

    my @header = PreComp::Constants::CommomHeader();

    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::GenObjRoot().$type.".h" );
    if( ! $FHD ) { return; }

    print $FHD "\n";
    print $FHD "#ifndef __t4_app_$type"."__\n";
    print $FHD "#define __t4_app_$type"."__\n";
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

    my $tuple;
    
    foreach $tuple ( @header ) {

        my ( $var_type, $var_name ) = split / /, $tuple;

        print $FHD "        $var_type $var_name;\n";

    }

    if ( $master_hash->{$type}->{implements} ne $type ) {

        my $implements = $master_hash->{$type}->{implements};

        my $section;
        my ( $var_name, $var_type );

        foreach $section ( "sub", "static", "pub" ) {

            print $FHD "\n        // $implements $section\n";

            foreach $var_name ( @{$master_hash->{$type}->{$section}->{order}} ) {

                $var_type = $master_hash->{$type}->{$section}->{data}->{$var_name};

                if ( exists $master_hash->{$implements}->{$section}->{data}->{$var_name} ) {

                    if ( $section =~ /sub/ ) {

                        print $FHD "        int $var_name;\n";
                    }
                    else {

                        print $FHD "        $var_type $var_name;\n";
                    }
                }
            }
        }

        foreach $section ( "sub", "static", "pub" ) {

            print $FHD "\n        // $type $section\n";

            foreach $var_name ( @{$master_hash->{$type}->{$section}->{order}} ) {

                $var_type = $master_hash->{$type}->{$section}->{data}->{$var_name};

                if ( not exists $master_hash->{$implements}->{$section}->{data}->{$var_name} ) {

                    if ( $section =~ /sub/ ) {

                        print $FHD "        int $var_name;\n";
                    }
                    else {

                        print $FHD "        $var_type $var_name;\n";
                    }
                }
            }


        }

    }
    else { 

        my $section;

        foreach $section ( "sub", "static", "pub" ) {

            print $FHD "\n        // $section\n";

            my ( $var_name, $var_type );

            foreach $var_name ( @{$master_hash->{$type}->{$section}->{order}} ) {

                $var_type = $master_hash->{$type}->{$section}->{data}->{$var_name};

                if ( $section =~ /sub/ ) {

                    print $FHD "        int $var_name;\n";
                }
                else {

                    print $FHD "        $var_type $var_name;\n";
                }


            }
        
        } 
    }
    print $FHD "    } $type;\n";
    print $FHD "\n";
    print $FHD "}\n";
    print $FHD "\n";
    print $FHD "#endif\n";

    PreComp::Utilities::CloseFile();
}

1;

