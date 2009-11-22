# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#

package PreComp::Sql;

use strict;
use warnings;

use PreComp::Utilities;
use PreComp::Constants;
use Data::Dumper;

sub GenerateExtraTables($$$$$);
sub GenerateExtraDummyData($$$$$$);
sub GenerateDummyData($$);

sub Generate($$) {
    my $master_hash = shift;
    my $type = shift;

    GenerateObjectTable( $master_hash, $type );

    GenerateDummyData( $master_hash, $type );

    my $section;
    my $type_num = $master_hash->{$type}->{type_id};

    foreach $section ( "static", "sub" ) {

        my ( $var_name, $var_type, $var_name_stripped );

        foreach $var_name ( @{$master_hash->{$type}->{$section}->{order}} ) {

            $var_name_stripped = PreComp::Utilities::StripBrackets( $var_name );
            $var_type = $master_hash->{$type}->{$section}->{data}->{$var_name};

            if ( exists $master_hash->{structures}->{data}->{$var_type} or PreComp::Utilities::IsArray( $var_name ) ) {

                GenerateExtraTables( $master_hash, $var_name, $var_type, $type, 0 );
                GenerateExtraDummyData( $master_hash, $var_name, $var_type, $type, 0, $type_num );

            }
        }
    }
 
}

sub GenerateExtraTables($$$$$) {
    my $master_hash = shift;
    my $var_name = shift;
    my $var_type = shift;
    my $table_name = shift;
    my $depth = shift;

    my $var_name_stripped = PreComp::Utilities::StripBrackets( $var_name ); 

    $table_name = $table_name."_".$var_name_stripped;
    
    if ( $var_name ne $var_name_stripped ) {
        $depth = $depth + 1;
    }

    if ( exists $master_hash->{structures}->{data}->{$var_type} ) {

        my ( $struct_var_name, $struct_var_type, $struct_var_name_stripped );


        foreach $struct_var_name ( @{$master_hash->{structures}->{data}->{$var_type}->{order}} ) {

            $struct_var_type = $master_hash->{structures}->{data}->{$var_type}->{data}->{$struct_var_name};

            if ( exists $master_hash->{structures}->{data}->{$struct_var_type} or PreComp::Utilities::IsArray( $struct_var_name ) ) {
                GenerateExtraTables( $master_hash, $struct_var_name, $struct_var_type, $table_name, $depth );
            }

        }

        my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::SqlRoot()."$table_name.table" );
        if( ! $FHD ) { return; }

        print $FHD "create table $table_name (\n";
        print $FHD "    id int";

        my $i;
        for ( $i = 1 ; $i <= $depth ; $i++ ) {

            print $FHD ",\n    ord$i int";
        }

        foreach $struct_var_name ( @{$master_hash->{structures}->{data}->{$var_type}->{order}} ) {

            if ( not ( exists $master_hash->{structures}->{data}->{$struct_var_type} or PreComp::Utilities::IsArray( $struct_var_name )) ) {
                $struct_var_type = $master_hash->{structures}->{data}->{$var_type}->{data}->{$struct_var_name};

                print $FHD ",\n    ".PreComp::Utilities::StripBrackets( $struct_var_name)." ".PreComp::Utilities::Type2Sql( $struct_var_type );
            }
        }

        print $FHD "\n);\n";
        PreComp::Utilities::CloseFile();
    }
    elsif ( PreComp::Utilities::IsArray( $var_name ) ) {

        my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::SqlRoot()."$table_name.table" );
        if( ! $FHD ) { return; }

        print $FHD "create table $table_name (\n";
        print $FHD "    id int";

        my $i;
        for ( $i = 1 ; $i < $depth ; $i++ ) {

            print $FHD ",\n    ord$i int";
        }

        my $array_size = PreComp::Utilities::GetArraySize( $master_hash, $var_name );

        for ( $i = 0 ; $i < $array_size ; $i++ ) {

            print $FHD ",\n    col$i int";
        }

        print $FHD "\n);\n";
        PreComp::Utilities::CloseFile();
    }
}

sub GenerateObjectTable($$) {
    my $master_hash = shift;
    my $type = shift;

    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::SqlRoot()."$type.table" );
    if( ! $FHD ) { return; }

    print $FHD "create table $type (\n";
    print $FHD "    id int";

    my $section;

    foreach $section ( "static", "sub" ) {

        my ( $var_name, $var_type, $var_name_stripped );

        foreach $var_name ( @{$master_hash->{$type}->{$section}->{order}} ) {

            $var_name_stripped = PreComp::Utilities::StripBrackets( $var_name ); 
            $var_type = $master_hash->{$type}->{$section}->{data}->{$var_name};

            if ( not ( exists $master_hash->{structures}->{data}->{$var_type} or PreComp::Utilities::IsArray( $var_name ))) {

                print $FHD ",\n    $var_name ".PreComp::Utilities::Type2Sql( $var_type );
            }
        }
    }

    print $FHD "\n";
    print $FHD ");\n";
    print $FHD "\n";


    PreComp::Utilities::CloseFile();

}

sub GenerateDummyData($$) {
    my $master_hash = shift;
    my $type = shift;
  
    my $obj_hash = $master_hash->{$type};

    my $PI = 3.14;

    my $tier = $master_hash->{$type}->{tier};
    my $type_num = $master_hash->{$type}->{type_id};

    my $FHD = PreComp::Utilities::OpenFile( $ENV{APP_ROOT}."/data/default_set/$type.sql" );
    if( ! $FHD ) { return; }

    print $FHD "delete from $type;\n";
    print $FHD "insert into object values ( $type_num, $type_num, $tier, \"$type"."_$type_num\", 1, 1 );\n";
    print $FHD "insert into $type values ( $type_num";

    my ( $var_name, $var_type );

    foreach $var_name ( @{$master_hash->{$type}->{static}->{order}} ) {

        $var_type = $master_hash->{$type}->{static}->{data}->{$var_name};
        
        if ( not ( exists $master_hash->{structures}->{data}->{$var_type} or PreComp::Utilities::IsArray( $var_name )) ) {
                print $FHD ", $PI";
        } 
    }

    foreach $var_name ( @{$master_hash->{$type}->{sub}->{order}} ) {

        $var_type = $master_hash->{$type}->{sub}->{data}->{$var_name};

        if ( ! PreComp::Utilities::IsArray( $var_name ) ) {
                print $FHD ", $master_hash->{$var_type}->{type_id}";
        }

    }

    print $FHD " );\n";

    PreComp::Utilities::CloseFile();
}

sub GenerateExtraDummyData($$$$$$) {
    my $master_hash = shift;
    my $var_name = shift;
    my $var_type = shift;
    my $table_name = shift;
    my $depth = shift;
    my $type_num = shift;

    my $var_name_stripped = PreComp::Utilities::StripBrackets( $var_name ); 

    my $PI = 3.14;

    $table_name = $table_name."_".$var_name_stripped;
    
    if ( $var_name ne $var_name_stripped ) {
        $depth = $depth + 1;
    }

    if ( exists $master_hash->{structures}->{data}->{$var_type} ) {

        my ( $struct_var_name, $struct_var_type, $struct_var_name_stripped );


        foreach $struct_var_name ( @{$master_hash->{structures}->{data}->{$var_type}->{order}} ) {

            $struct_var_type = $master_hash->{structures}->{data}->{$var_type}->{data}->{$struct_var_name};

            if ( exists $master_hash->{structures}->{data}->{$struct_var_type} or PreComp::Utilities::IsArray( $struct_var_name ) ) {
                GenerateExtraDummyData( $master_hash, $struct_var_name, $struct_var_type, $table_name, $depth, $type_num );
            }

        }

        my $FHD = PreComp::Utilities::OpenFile( $ENV{APP_ROOT}."/data/default_set/$table_name.sql" );
        if( ! $FHD ) { return; }

        print $FHD "delete from $table_name;\n";
        print $FHD "insert into $table_name values ( $type_num";

        my $i;
        for ( $i = 1 ; $i <= $depth ; $i++ ) {

            print $FHD ", 0";
        }

        foreach $struct_var_name ( @{$master_hash->{structures}->{data}->{$var_type}->{order}} ) {

            if ( not ( exists $master_hash->{structures}->{data}->{$struct_var_type} or PreComp::Utilities::IsArray( $struct_var_name )) ) {

                print $FHD ", $PI";
            }
        }

        print $FHD " );\n";
        PreComp::Utilities::CloseFile();
    }
    elsif ( PreComp::Utilities::IsArray( $var_name ) ) {

        my $FHD = PreComp::Utilities::OpenFile( $ENV{APP_ROOT}."/data/default_set/$table_name.sql" );
        if( ! $FHD ) { return; }

        print $FHD "delete from $table_name;\n";
        print $FHD "insert into $table_name values ( $type_num";

        my $i;
        for ( $i = 1 ; $i <= $depth ; $i++ ) {

            print $FHD ", 1";
        }

        print $FHD ", $PI";
        print $FHD " );\n";
        PreComp::Utilities::CloseFile();
    }
}

1;
