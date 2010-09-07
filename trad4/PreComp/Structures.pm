# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#

package PreComp::Structures;

use warnings;
use strict;

use Data::Dumper;
use PreComp::Utilities;

sub Generate($) {
    my $struct_hash = shift;

    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::GenObjRoot()."structures.h" );
    if( ! $FHD ) { return; }

    print $FHD "\n";
    print $FHD "#ifndef __t4_app_structures_h__\n";
    print $FHD "#define __t4_app_structures_h__\n";
    print $FHD "\n";
    print $FHD "#include \"constants.h\"\n";
    print $FHD "#include \"aliases.h\"\n";
    print $FHD "#include \"enums.h\"\n";
    print $FHD "\n";

    my ( $structure, $var );

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

sub Validate($) {
    my $master_hash = shift;

    my ( $structure, $var_name );

    foreach $structure ( @{$master_hash->{structures}->{order}} ) {

        foreach $var_name ( @{$master_hash->{structures}->{data}->{$structure}->{order}} ) {

            if ( PreComp::Utilities::IsArray( $var_name ) ) {

                if ( ! PreComp::Utilities::GetArraySize( $master_hash, $var_name ) ) {

                    my $size = $var_name;
                    $size =~ s/.*\[//g;
                    $size =~ s/\]//g;

                    print "Error: Structure \'$structure\' has an array variable \'$var_name\' but $size is not defined in constants.t4s.\n";
                    PreComp::Utilities::ExitOnError();
                }
            }

            my $var_type = $master_hash->{structures}->{data}->{$structure}->{data}->{$var_name};

            if ( $var_type !~ /^int$|^double$|^float$|^long$|^char$/ )
            {
                if ( exists $master_hash->{structures}->{data}->{$var_type} )
                {
                    next;
                }

                if ( exists $master_hash->{enums}->{$var_type} )
                {
                    next;
                }

                if ( exists $master_hash->{aliases}->{data}->{$var_type} )
                {
                    next;
                }

                print "Error: Structure \'$structure\' has a variable \'$var_name\' with an unknown type \'$var_type\'. It's not:\n";
                print "    a) an int, double, float, long or char.\n";
                print "    b) another structure, as defined in structures.t4s\n";
                print "    c) an enum, as defined in enums.t4s\n";
                print "    d) an alias, as defined in aliases.t4s\n";

                PreComp::Utilities::ExitOnError();

            }

        }

    }
}

1;

