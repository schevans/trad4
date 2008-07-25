# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#

package PreComp::Macros;

use PreComp::Utilities;
use PreComp::Constants;
use Data::Dumper;

sub Generate($) {
    my $obj_hash = shift;

    foreach $name ( keys %{$obj_hash} ) {

        my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::GenObjRoot().$name."_macros.h" );


        #print_licence_header( $FHD );
             
                                              
        print $FHD "\n";
        print $FHD "/*======================================================================\n";
        print $FHD "\n";
        print $FHD "The following variables are in-scope for calculate_$name():\n";
        print $FHD "\n";

        if ( keys %{$obj_hash->{$name}->{data}->{pub}} ) {
            print $FHD "pub:\n";
        }

        foreach $var ( keys %{$obj_hash->{$name}->{data}->{pub}} ) {

#PreComp::Utilities::PrintSection( $FHD, $obj_hash->{$name}->{data}->{pub}, "    " );

            print $FHD "    $obj_hash->{$name}->{data}->{pub}->{$var} $name"."_$var\n";
        }

        if ( keys %{$obj_hash->{$name}->{data}->{static}} or keys %{$obj_hash->{$name}->{data}->{static_vec}} ) {
            print $FHD "\nstatic:\n";
        }

        foreach $var ( keys %{$obj_hash->{$name}->{data}->{static}} ) {

            print $FHD "    $obj_hash->{$name}->{data}->{static}->{$var} $name"."_$var\n";

        }

        foreach $var ( keys %{$obj_hash->{$name}->{data}->{static_vec}} ) {

            print $FHD "    $obj_hash->{$name}->{data}->{static_vec}->{$var} $name"."_$var\n";

        }

        print $FHD "\n";

        if ( keys %{$obj_hash->{$name}->{data}->{sub}} ) {
            print $FHD "\nsub:\n";
        }

        foreach $var ( keys %{$obj_hash->{$name}->{data}->{sub}} ) {

            foreach $var2 ( keys %{$obj_hash->{$var}->{data}->{pub}} ) {

                print $FHD "    $obj_hash->{$var}->{data}->{pub}->{$var2} $var"."_$var2\n";
            }

            foreach $var2 ( keys %{$obj_hash->{$var}->{data}->{static}} ) {

                print $FHD "    $obj_hash->{$var}->{data}->{static}->{$var2} $var"."_$var2\n";
            }

            foreach $var2 ( keys %{$obj_hash->{$var}->{data}->{static_vec}} ) {

                print $FHD "    $obj_hash->{$var}->{data}->{static_vec}->{$var2} $var"."_$var2\n";

            }

            print $FHD "\n";

        }

        print $FHD "======================================================================*/\n";
        print $FHD "\n";
        print $FHD "#ifndef __$name"."_marcos_h__\n";
        print $FHD "#define __$name"."_marcos_h__\n";
        print $FHD "\n";

        print $FHD "// $name macros\n";

        foreach $var ( keys %{$obj_hash->{$name}->{data}->{pub}} ) {

            $var =~ s/\[.*]$//;
            print $FHD "#define $name"."_$var (($name*)obj_loc[id])->$var\n";

        }

        foreach $var ( keys %{$obj_hash->{$name}->{data}->{static}} ) {

            print $FHD "#define $name"."_$var (($name*)obj_loc[id])->$var\n";

        }


        foreach $var ( keys %{$obj_hash->{$name}->{data}->{static_vec}} ) {

            $var =~ s/\[.*]$//;

            print $FHD "#define $name"."_$var (($name*)obj_loc[id])->$var\n";

        }



        foreach $var ( keys %{$obj_hash->{$name}->{data}->{sub}} ) {

            print $FHD "\n";
            print $FHD "// sub $var macros\n";

            foreach $var2 ( keys %{$obj_hash->{$var}->{data}->{pub}} ) {

                $var2 =~ s/\[.*]$//;
                print $FHD "#define $var"."_$var2 (($var*)obj_loc[(($name*)obj_loc[id])->$var])->$var2\n";
            }

            foreach $var2 ( keys %{$obj_hash->{$var}->{data}->{static}} ) {

                print $FHD "#define $var"."_$var2 (($var*)obj_loc[(($name*)obj_loc[id])->$var])->$var2\n";
            }

            foreach $var2 ( keys %{$obj_hash->{$var}->{data}->{static_vec}} ) {

                $var2 =~ s/\[.*]$//;

                print $FHD "#define $var"."_$var2 (($var*)obj_loc[(($name*)obj_loc[id])->$var])->$var2\n";

            }

        }

        print $FHD "\n";
        print $FHD "#endif\n";
        print $FHD "\n";

        PreComp::Utilities::CloseFile();
    }
}

1;

