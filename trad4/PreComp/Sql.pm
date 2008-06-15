# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#

package PreComp::Sql;

use PreComp::Utilities;
use PreComp::Constants;
use Data::Dumper;

sub generate_table($);
sub generate_dummy_data($$);

sub Generate($$) {
    my $master_hash = shift;
    my $name = shift;

    my $obj_hash = $master_hash->{$name};

    generate_table($obj_hash);

    generate_dummy_data( $master_hash, $name );
}

sub generate_dummy_data($$) {
    my $master_hash = shift;
    my $name = shift;
    
    my $obj_hash = $master_hash->{$name};

    my $PI = 3.14;

    my $name = $obj_hash->{name};
    my $type_num = $obj_hash->{type_num};

    my $FHD = PreComp::Utilities::OpenFile( $ENV{INSTANCE_ROOT}."/data/default_set/$name.sql" );

    #print_licence_header( $FHD );

    print $FHD "delete from $name;\n";
    print $FHD "insert into object values ( $type_num, $type_num, \"$name"."_$type_num\", 0, 1 );\n";
    print $FHD "insert into $name values ( $type_num";

    foreach $key ( keys %{$obj_hash->{data}->{static}} ) {

        print $FHD ", $PI";
    }

    foreach $key ( keys %{$obj_hash->{data}->{sub}} ) {

        print $FHD ", $master_hash->{$key}->{type_num}";

    }

    print $FHD " );\n";

    PreComp::Utilities::CloseFile();
}

sub generate_table($) {
    my $obj_hash = shift;

    my $name = $obj_hash->{name};

    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::SqlRoot()."$name.table" );

    #print_licence_header( $FHD );

    print $FHD "create table $name (\n";
    print $FHD "    id int";

    foreach $key ( keys %{$obj_hash->{data}->{static}} ) {

        print $FHD ",\n    $key ".PreComp::Utilities::Type2Sql($obj_hash->{data}->{static}->{$key});
    }

    foreach $key ( keys %{$obj_hash->{data}->{feed_in}} ) {

        print $FHD ",\n    $key ".PreComp::Utilities::Type2Sql($obj_hash->{data}->{static}->{$key});
    }

    foreach $key ( keys %{$obj_hash->{data}->{sub}} ) {

        print $FHD ",\n    $key ".PreComp::Utilities::Type2Sql($obj_hash->{data}->{sub}->{$key});
    }

    print $FHD "\n";
    print $FHD ");\n";
    print $FHD "\n";


    PreComp::Utilities::CloseFile();
}

1;
