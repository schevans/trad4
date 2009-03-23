# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#

package PreComp::Macros;

use PreComp::Utilities;
use PreComp::Constants;
use Data::Dumper;

sub Generate($$) {
    my $obj_hash = shift;
    my $struct_hash = shift;

    foreach $name ( keys %{$obj_hash} ) {

        my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::GenObjRoot().$name."_macros.h" );
        if( ! $FHD ) { return; }

        print $FHD "\n";
        print $FHD "/*======================================================================\n";
        print $FHD "\n";
        print $FHD "The following variables are in-scope for calculate_$name():\n";
        print $FHD "\n";

        if ( keys %{$obj_hash->{$name}->{data}->{pub}} or keys %{$obj_hash->{$name}->{data}->{pub_vec}} ) {
            print $FHD "pub:\n";
        }

        foreach $var ( keys %{$obj_hash->{$name}->{data}->{pub}} ) {

            print $FHD "    $obj_hash->{$name}->{data}->{pub}->{$var} $name"."_$var\n";
        }

        foreach $pub_vec_name ( keys %{$obj_hash->{$name}->{data}->{pub_vec}} ) {

            $pub_vec_type = $obj_hash->{$name}->{data}->{pub_vec}->{$pub_vec_name};

            $pub_vec_short = $pub_vec_name;
            $pub_vec_short =~ s/\[.*\]//g;

            if ( $struct_hash->{$pub_vec_type} ) {

                foreach $key ( keys %{$struct_hash->{$pub_vec_type}->{data}} ) {

                    print $FHD "    $struct_hash->{$pub_vec_type}->{data}->{$key} $name"."_$pub_vec_short"."_$key( index );\n";
                }
            }

            print $FHD "    $pub_vec_type $name"."_$pub_vec_name;\n";
        }

        if ( keys %{$obj_hash->{$name}->{data}->{static}} or keys %{$obj_hash->{$name}->{data}->{static_vec}} ) {
            print $FHD "\nstatic:\n";
        }

        foreach $var ( @{$obj_hash->{$name}->{data}->{static_order}} ) {

            print $FHD "    $obj_hash->{$name}->{data}->{static}->{$var} $name"."_$var\n";

        }

        foreach $static_vec_name ( @{$obj_hash->{$name}->{data}->{static_vec_order}} ) {

            $static_vec_type = $obj_hash->{$name}->{data}->{static_vec}->{$static_vec_name};

            $static_vec_short = $static_vec_name;
            $static_vec_short =~ s/\[.*\]//g;

            if ( $struct_hash->{$static_vec_type} ) {

                foreach $key ( keys %{$struct_hash->{$static_vec_type}->{data}} ) {

                    print $FHD "    $struct_hash->{$static_vec_type}->{data}->{$key} $name"."_$static_vec_short"."_$key( index );\n";
                }
            }

            print $FHD "    $static_vec_type $name"."_$static_vec_name;\n";

        }

        print $FHD "\n";

        if ( keys %{$obj_hash->{$name}->{data}->{sub}} ) {
            print $FHD "\nsub:\n";
        }

        foreach $var ( @{$obj_hash->{$name}->{data}->{sub_order}} ) {

            print $FHD "    $var:\n";

            foreach $var2 ( keys %{$obj_hash->{$obj_hash->{$name}->{data}->{sub}->{$var}}->{data}->{pub}} ) {

                print $FHD "        $obj_hash->{$obj_hash->{$name}->{data}->{sub}->{$var}}->{data}->{pub}->{$var2} $var"."_$var2\n";
            }

            foreach $var2 ( keys %{$obj_hash->{$obj_hash->{$name}->{data}->{sub}->{$var}}->{data}->{static}} ) {

                print $FHD "        $obj_hash->{$obj_hash->{$name}->{data}->{sub}->{$var}}->{data}->{static}->{$var2} $var"."_$var2\n";
            }

            foreach $var2 ( keys %{$obj_hash->{$obj_hash->{$name}->{data}->{sub}->{$var}}->{data}->{static_vec}} ) {

                print $FHD "        $obj_hash->{$obj_hash->{$name}->{data}->{sub}->{$var}}->{data}->{static_vec}->{$var2} $var"."_$var2\n";

            }

            print $FHD "\n";

        }

        foreach $var ( @{$obj_hash->{$name}->{data}->{sub_vec_order}} ) {

            $var_short = $var;
            $var_short =~ s/\[.*\]//g;

            $var_type = $obj_hash->{$name}->{data}->{sub_vec}->{$var};

            print $FHD "    $var_type $name"."_$var\n";

            foreach $var2 ( keys %{$obj_hash->{$obj_hash->{$name}->{data}->{sub_vec}->{$var}}->{data}->{pub}} ) {

                print $FHD "        $obj_hash->{$obj_hash->{$name}->{data}->{sub_vec}->{$var}}->{data}->{pub}->{$var2} $name"."_$var_short"."_$var2( index )\n";
            }

            foreach $var2 ( keys %{$obj_hash->{$obj_hash->{$name}->{data}->{sub_vec}->{$var}}->{data}->{static}} ) {

                print $FHD "        $obj_hash->{$obj_hash->{$name}->{data}->{sub_vec}->{$var}}->{data}->{static}->{$var2} $name"."_$var_short"."_$var2( index )\n";
            }

            print $FHD "\n";

        }


        print $FHD "======================================================================*/\n";
        print $FHD "\n";
        print $FHD "#ifndef __$name"."_macros_h__\n";
        print $FHD "#define __$name"."_macros_h__\n";
        print $FHD "\n";




        print $FHD "// $name macros\n";

        foreach $var ( keys %{$obj_hash->{$name}->{data}->{pub}} ) {

            $var =~ s/\[.*]$//;
            print $FHD "#define $name"."_$var (($name*)obj_loc[id])->$var\n";

        }

        print_macro_vec( $FHD, $name, $obj_hash, $struct_hash, "pub" );

        foreach $var ( keys %{$obj_hash->{$name}->{data}->{static}} ) {

            print $FHD "#define $name"."_$var (($name*)obj_loc[id])->$var\n";

        }

        print_macro_vec( $FHD, $name, $obj_hash, $struct_hash, "static" );

        foreach $var ( keys %{$obj_hash->{$name}->{data}->{sub}} ) {

            $var_type = $obj_hash->{$name}->{data}->{sub}->{$var};

            print $FHD "\n";
            print $FHD "// sub $var macros\n";

            foreach $var2 ( keys %{$obj_hash->{$var_type}->{data}->{pub}} ) {

                $var2 =~ s/\[.*]$//;
                print $FHD "#define $var"."_$var2 (($var_type*)obj_loc[(($name*)obj_loc[id])->$var])->$var2\n";
            }

            print_macro_sub_vec( $FHD, $var, $var_type, $obj_hash, $struct_hash, "pub" );

            foreach $var2 ( keys %{$obj_hash->{$var_type}->{data}->{static}} ) {

                print $FHD "#define $var"."_$var2 (($var_type*)obj_loc[(($name*)obj_loc[id])->$var])->$var2\n";
            }

            print_macro_sub_vec( $FHD, $var, $var_type, $obj_hash, $struct_hash, "static" );

        }

        print_macro_vec( $FHD, $name, $obj_hash, $struct_hash, "sub" );

        foreach $var ( keys %{$obj_hash->{$name}->{data}->{sub_vec}} ) {

            $var_type = $obj_hash->{$name}->{data}->{sub_vec}->{$var};

            my $var_short = $var;
            $var_short =~ s/\[.*]$//;

            print $FHD "\n";
            print $FHD "// sub $var macros\n";

            foreach $var2 ( ( keys %{$obj_hash->{$var_type}->{data}->{pub}}, keys %{$obj_hash->{$var_type}->{data}->{static}} ) ) {

                $var2 =~ s/\[.*]$//;

                print $FHD "#define $name"."_$var_short"."_$var2(index) (($var_type*)obj_loc[$name"."_$var_short\[index\]])->$var2\n";

            }


        }

        print $FHD "\n";
        print $FHD "#endif\n";
        print $FHD "\n";

        PreComp::Utilities::CloseFile();
    }
}

sub print_macro_sub_vec($) {
    my $FHD = shift;
    my $var = shift;
    my $var_type = shift;
    my $obj_hash = shift;
    my $struct_hash = shift;
    my $section = shift;
    my $vec_section = $section."_vec";

    foreach $vec_name ( keys %{$obj_hash->{$var_type}->{data}->{$vec_section}} ) {

        $vec_type = $obj_hash->{$var_type}->{data}->{$vec_section}->{$vec_name};

        $vec_short = $vec_name;
        $vec_short =~ s/\[.*\]//g;

        print $FHD "#define $var"."_$vec_short (($var_type*)obj_loc[(($name*)obj_loc[id])->$var])->$vec_short\n";

        if ( $struct_hash->{$vec_type} ) {

            foreach $key ( @{$struct_hash->{$vec_type}{order}} ) {

                print $FHD "#define $var"."_$vec_short"."_$key( index ) $var"."_$vec_short\[index\].$key\n";
            }
        }
        else {
            # Nothing here I think.
        }


    }
}

sub print_macro_vec($) {
    my $FHD = shift;
    my $name = shift;
    my $obj_hash = shift;
    my $struct_hash = shift;
    my $section = shift;
    my $vec_section = $section."_vec";

    foreach $vec_name ( keys %{$obj_hash->{$name}->{data}->{$vec_section}} ) {

        $vec_type = $obj_hash->{$name}->{data}->{$vec_section}->{$vec_name};

        $vec_short = $vec_name;
        $vec_short =~ s/\[.*\]//g;

        if ( $struct_hash->{$vec_type} ) {

            foreach $key ( @{$struct_hash->{$vec_type}{order}} ) {

                print $FHD "#define $name"."_$vec_short"."_$key( index ) (($name*)obj_loc[id])->$vec_short\[index\].$key\n";
            }
        }

        print $FHD "#define $name"."_$vec_short (($name*)obj_loc[id])->$vec_short\n";
    }
}

#######################################################
# pv3 stuff..

use strict;

sub GenerateNew($$) {
    my $master_hash = shift;
    my $type = shift;

    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::GenObjRoot().$type."_new_macros.h" );
    if( ! $FHD ) { return; }

    print $FHD "\n";
    print $FHD "/*======================================================================\n";
    print $FHD "\n";
    print $FHD "The following variables are in-scope for calculate_$type():\n";
    print $FHD "\n";

    my $section;

    foreach $section ( PreComp::Utilities::GetSections( $master_hash->{$type} )) {

        print $FHD "$section:\n";

        my ( $var_name, $var_type );

        foreach $var_name ( @{$master_hash->{$type}->{$section}->{order}} ) {

            $var_type = $master_hash->{$type}->{$section}->{data}->{$var_name};

            if ( exists $master_hash->{$var_type} and $section =~ /sub/ ) {

                print $FHD "    $var_type:\n";

                my $sub_section;

                foreach $sub_section ( "static", "pub" ) {

                    my ( $sub_var_name, $sub_var_type );

                    foreach $sub_var_name ( @{$master_hash->{$var_type}->{$sub_section}->{order}} ) {

                        $sub_var_type = $master_hash->{$var_type}->{$sub_section}->{data}->{$sub_var_name};

                        print $FHD "        $sub_var_type $var_name"."_$sub_var_name\n";
 
                    }
                }
            }
            else {

                print $FHD "    $var_type $var_name\n";
            }
        }

        print $FHD "\n";
    }

    print $FHD "======================================================================*/\n";
    print $FHD "\n";

    
    PreComp::Utilities::CloseFile();

}


1;

