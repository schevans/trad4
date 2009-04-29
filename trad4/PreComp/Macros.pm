# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#

package PreComp::Macros;

use strict;
use warnings;

use PreComp::Utilities;
use PreComp::Constants;
use Data::Dumper;


sub Generate($$) {
    my $master_hash = shift;
    my $type = shift;

    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::GenObjRoot().$type."_macros.h" );
    if( ! $FHD ) { return; }

    my $file_section;
    foreach $file_section ( "comment", "code" ) {

        my $code_comment;

        if ( $file_section =~ /comment/ ) {

            print $FHD "\n";
            print $FHD "/*======================================================================\n";
            print $FHD "\n";
            print $FHD "The following variables are in-scope for calculate_$type():\n";
            print $FHD "\n";

        }
        else {

            $code_comment = "// ";

            print $FHD "#ifndef __$type"."_macros_h__\n";
            print $FHD "#define __$type"."_macros_h__\n";
            print $FHD "\n";

        }

        my $section;
        foreach $section ( PreComp::Utilities::GetSections( $master_hash->{$type} )) {

            my $printable;

            foreach $printable ( GetPrintablesFromSection( $master_hash, $master_hash->{$type}->{$section}, "\t" )) {

                if ( $section =~ /sub/ ) {

                    if ( $printable->{code} =~ /obj_loc/ ) {
                       
                        $printable->{code} =~ s/\[id/[(($type*)obj_loc\[id/;
                    }
                    else {
                        $printable->{code} = "(($type*)obj_loc[id])->".$printable->{code};
                        $printable->{name} = $type."_$printable->{name}";
                    }

                    $printable->{code} =~ s/\[/\[index_/g;
                    $printable->{code} =~ s/\[index_id\]/\[id\]/;
                    $printable->{code} =~ s/obj_loc\[index_/obj_loc\[/;
                }
                else {

                    $printable->{name} = $type."_$printable->{name}";

                    $printable->{code} =~ s/\[/\[index_/g;
                    $printable->{code} = "(($type*)obj_loc[id])->".$printable->{code};

                }


                if ( $file_section =~ /comment/ ) {

                    print $FHD "$printable->{type} ".NameToFunction( $printable->{name} )."\n";
                }
                else {
                    print $FHD "#define ".NameToFunction( $printable->{name} )." $printable->{code}\n";
                }

            }

        }

        if ( $file_section =~ /comment/ ) {

            print $FHD "======================================================================*/\n";
            print $FHD "\n";

        }
        else {

            print $FHD "#endif\n";
            print $FHD "\n";
        }

    }
    
    PreComp::Utilities::CloseFile();

}

sub NameToFunction($) {
    my $name = shift;

    while ( $name =~ /\[/g ) {

        my @tmp_tuple;

        @tmp_tuple = split /\[/, $name;
        @tmp_tuple = split /\]/, $tmp_tuple[1];

        my $array_length = $tmp_tuple[0];

        $name =~ s/\[$array_length\]//;

        $name =~ s/$/(index_$array_length,/;

    }

    $name =~ s/\(/( /g;
    $name =~ s/,\(/,/g;
    $name =~ s/,$/ )/g;

    return $name;
}

sub GetPrintablesFromSection($$$) {
    my $master_hash = shift;
    my $section_hash = shift;
    my $indent = shift;

    my @ret_array;

    $indent = $indent."\t";

    my ( $var_name, $var_type );

    foreach $var_name ( @{$section_hash->{order}} ) {

        $var_type = $section_hash->{data}->{$var_name};

        if ( exists $master_hash->{$var_type} ) {

            #print $indent."Var $var_name/$var_type is t4 type. Recursing..\n";

my %printable;
$printable{name} = $var_name;
$printable{type} = $var_type;
$printable{code} = $var_name;

            push @ret_array, \%printable;

            my $section;
            foreach $section ( "static", "pub" ) {

                #print $indent."Section: $section\n";

my $tmp;
 
                foreach $tmp ( GetPrintablesFromSection( $master_hash, $master_hash->{$var_type}->{$section}, $indent ) ) {

                    $tmp->{name} = $var_name."_".$tmp->{name};
                    $tmp->{code} =~ s/^/(($var_type*)obj_loc[id])->$var_name])->/g;

                    push @ret_array, $tmp;
                }
            }

        }
        elsif ( exists $master_hash->{structures}->{$var_type} ) {

            #print $indent."Var $var_name/$var_type is struct. Recursing..\n";
           
my %printable;
$printable{name} = $var_name;
$printable{type} = $var_type;
$printable{code} = $var_name;

#print Dumper( \%printable );
#print "\n";

            push @ret_array, \%printable;
my $tmp;
 
            foreach $tmp ( GetPrintablesFromSection( $master_hash, $master_hash->{structures}->{$var_type}, $indent ) ) {

                $tmp->{name} = $var_name."_$tmp->{name}";
                $tmp->{code} = "$var_name.".$tmp->{code};

                push @ret_array, $tmp;

            }

        }
        else {
       
#            print $indent."Var $var_name/$var_type is simple. Returning\n";

my %printable;
#print Dumper( %printable );
$printable{name} = $var_name;
$printable{type} = $var_type;
$printable{code} = $var_name;


            push @ret_array, \%printable;

            #GetTypesNames($$)
        }
    } 

    return @ret_array;
}

1;

