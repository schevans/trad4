# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#

package PreComp::Macros;

use strict;
use warnings;

use PreComp::Utilities;
use PreComp::Constants;
use Data::Dumper;

sub GetPrintablesFromSection($$$);

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

        }
        else {

            $code_comment = "// ";

            print $FHD "#ifndef __$type"."_macros_h__\n";
            print $FHD "#define __$type"."_macros_h__\n";
            print $FHD "\n";

        }

        my $section;
        foreach $section ( PreComp::Utilities::GetSections( $master_hash->{$type} )) {

            if ( $file_section =~ /comment/ ) {

                print $FHD "\n$section:\n";
            }

            my $printable;

            foreach $printable ( GetPrintablesFromSection( $master_hash, $master_hash->{$type}->{$section}, "0" )) {

                if ( $section =~ /sub/ ) {

                    if ( $printable->{code} =~ /obj_loc/ ) {
                       
                        $printable->{code} =~ s/\[id/[((t4::$type*)obj_loc\[id/;
                    }
                    else {
                        $printable->{code} = "((t4::$type*)obj_loc[id])->".$printable->{code};
                        $printable->{name} = $type."_$printable->{name}";
                    }

                    $printable->{code} =~ s/\[/\[index_/g;
                    $printable->{code} =~ s/\[index_id\]/\[id\]/;
                    $printable->{code} =~ s/obj_loc\[index_/obj_loc\[/;
                }
                else {

                    $printable->{name} = $type."_$printable->{name}";

                    $printable->{code} =~ s/\[/\[index_/g;
                    $printable->{code} = "((t4::$type*)obj_loc[id])->".$printable->{code};

                }

                if ( $file_section =~ /comment/ ) {

                    my $description = NameToFunctionDescription( $printable->{name} );
                    print $FHD "\t$printable->{type} $description\n";
                }
                else {

                    my $function = NameToFunction( $printable->{name} );

                    if ( $function =~ /\( \w+ \)/ and $printable->{code} =~ /\[\w+\]$/ ) {

                        $function =~ s/\(.*\)//;
                        $printable->{code} =~ s/\[\w+\]$//;
                    }

                    print $FHD "#define $function $printable->{code}\n";
                }

            }

        }

        if ( $file_section =~ /comment/ ) {

            print $FHD "\n======================================================================*/\n";
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

sub NameToFunctionDescription($) {
    my $name = shift;

    if ( PreComp::Utilities::IsArray( $name )) {

        return $name;
    }

    while ( $name =~ /\[/g ) {

        my @tmp_tuple;

        @tmp_tuple = split /\[/, $name;
        @tmp_tuple = split /\]/, $tmp_tuple[1];

        my $array_length = $tmp_tuple[0];

        $name =~ s/\[$array_length\]//;

        $name =~ s/$/($array_length,/;

    }

    $name =~ s/\(/( /g;
    $name =~ s/,\(/,/g;
    $name =~ s/,$/ )/g;

    return $name;
}


sub GetPrintablesFromSection($$$) {
    my $master_hash = shift;
    my $section_hash = shift;
    my $depth = shift;

    my @ret_array;

    $depth = $depth+1;

    my ( $var_name, $var_type );

    foreach $var_name ( @{$section_hash->{order}} ) {

        $var_type = $section_hash->{data}->{$var_name};
        my %printable;
        my $sub_printable;

        $printable{name} = $var_name;
        $printable{type} = $var_type;
        $printable{code} = $var_name;
        $printable{depth} = $depth;

        push @ret_array, \%printable;

        if ( exists $master_hash->{$var_type} ) {

            my $section;
            foreach $section ( "static", "pub" ) {

                foreach $sub_printable ( GetPrintablesFromSection( $master_hash, $master_hash->{$var_type}->{$section}, $depth ) ) {

                    $sub_printable->{name} = $var_name."_".$sub_printable->{name};
                    $sub_printable->{code} =~ s/^/((t4::$var_type*)obj_loc[id])->$var_name])->/g;

                    push @ret_array, $sub_printable;
                }
            }

        }
        elsif ( exists $master_hash->{structures}->{data}->{$var_type} ) {

            foreach $sub_printable ( GetPrintablesFromSection( $master_hash, $master_hash->{structures}->{data}->{$var_type}, $depth ) ) {

                $sub_printable->{name} = $var_name."_$sub_printable->{name}";
                $sub_printable->{code} = "$var_name.".$sub_printable->{code};

                push @ret_array, $sub_printable;

            }

        }
    } 

    return @ret_array;
}

1;

