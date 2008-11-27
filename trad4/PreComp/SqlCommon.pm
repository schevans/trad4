# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#

package PreComp::SqlCommon;

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

    #print_licence_header( $FHD );

    my $object_type;

    print $FHD "delete from object_types;\n";

    foreach $object_type ( keys %{$master_hash} ) {

        print $FHD "insert into object_types values ( $master_hash->{$object_type}->{type_num}, \"$master_hash->{$object_type}->{name}\", $master_hash->{$object_type}->{tier}, 1 );\n";
    }

    PreComp::Utilities::CloseFile();
}
1;
