# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#

package PreComp::SqlCommon;

use PreComp::Utilities;

use warnings;
use strict;

use PreComp::Utilities;
use PreComp::Constants;
use Data::Dumper;

sub generate_object_types($);
sub generate_indices($);

sub Generate($) {
    my $master_hash = shift;

    generate_object_types( $master_hash );

    generate_indices( $master_hash );
}

sub generate_indices($) {
    my $master_hash = shift;

    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::SqlRoot()."indices.sql" );
    if( ! $FHD ) { return; }

    my $object_type;

    print $FHD "create index object_1 on object (id);\n";

    foreach $object_type ( keys %{$master_hash} ) {

        print $FHD "create index $object_type"."_1 on $object_type (id);\n";
    }

    PreComp::Utilities::CloseFile();
}

sub generate_object_types($) {
    my $master_hash = shift;
    
    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::SqlRoot()."object_types.sql" );
    if( ! $FHD ) { return; }

    my $object_type;

    print $FHD "delete from object_types;\n";

    foreach $object_type ( keys %{$master_hash} ) {

        print $FHD "insert into object_types values ( $master_hash->{$object_type}->{type_num}, \"$master_hash->{$object_type}->{name}\", 1 );\n";
    }

    PreComp::Utilities::CloseFile();
}

#######################################################
# pv3 stuff..

use strict;

sub GenerateNew($) {
    my $master_hash = shift;

    GenerateStructureTables( $master_hash );

}

sub GenerateStructureTables($) {
    my $master_hash = shift;

    my $structure;

    foreach $structure ( keys %{$master_hash->{structures}} ) {

        my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::SqlRoot()."$structure.table" );
        if( ! $FHD ) { return; }

        print $FHD "create table $structure (\n";
        print $FHD "    id int,\n";
        print $FHD "    name char";

        my ( $var_name, $var_type );

        foreach $var_name ( @{$master_hash->{structures}->{$structure}->{order}} ) {

            $var_type = $master_hash->{structures}->{$structure}->{data}->{$var_name};

#print "VN: $structure: $var_name/$var_type\n";

            if ( exists $master_hash->{structures}->{$var_type} ) {


                print $FHD ",\n    ".PreComp::Utilities::StripBrackets( $var_name)." ".PreComp::Utilities::Type2Sql( $var_type );

            }
            else {

                print $FHD ",\n    ".PreComp::Utilities::StripBrackets( $var_name)." ".PreComp::Utilities::Type2Sql( $var_type );

            }



        }

        print $FHD "\n);\n";
        PreComp::Utilities::CloseFile();
        

    }
}


1;









