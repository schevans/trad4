# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#

package PreComp::Sql;

use PreComp::Utilities;
use PreComp::Constants;
use Data::Dumper;

sub generate_table($);
sub generate_dummy_data($$);
sub generate_vec_tables($$);
sub generate_vec_dummy_data($$$);

sub Generate($$$) {
    my $master_hash = shift;
    my $struct_hash = shift;
    my $name = shift;

    my $obj_hash = $master_hash->{$name};

    generate_table($obj_hash);

    generate_dummy_data( $master_hash, $name );

    if ( defined $obj_hash->{data}->{static_vec} ) {

        generate_vec_tables( $obj_hash, $struct_hash );
        generate_vec_dummy_data( $master_hash, $name, $struct_hash );
    }

}

sub generate_dummy_data($$) {
    my $master_hash = shift;
    my $name = shift;
   
    my $obj_hash = $master_hash->{$name};

    my $PI = 3.14;

    my $name = $obj_hash->{name};
    my $type_num = $obj_hash->{type_num};

    my $FHD = PreComp::Utilities::OpenFile( $ENV{APP_ROOT}."/data/default_set/$name.sql" );

    #print_licence_header( $FHD );

    print $FHD "delete from $name;\n";
    print $FHD "insert into object values ( $type_num, $type_num, \"$name"."_$type_num\", 0, 1 );\n";
    print $FHD "insert into $name values ( $type_num";

    foreach $key ( @{$obj_hash->{data}->{static_order}} ) {

        print $FHD ", $PI";
    }

    foreach $key ( @{$obj_hash->{data}->{sub_order}} ) {

        print $FHD ", $master_hash->{$obj_hash->{data}->{sub}->{$key}}->{type_num}";

    }

    print $FHD " );\n";

    PreComp::Utilities::CloseFile();
}

sub generate_vec_tables($$) {
    my $obj_hash = shift;
    my $struct_hash = shift;


    foreach $key ( keys %{$obj_hash->{data}->{static_vec}} ) {

        $static_vec_short = $key;
        $static_vec_short =~ s/\[.*\]//g;

        my $name = $obj_hash->{name}."_".$static_vec_short;

        my $static_vec_type = $obj_hash->{data}->{static_vec}->{$key};

        my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::SqlRoot()."$name.table" );

        print $FHD "create table $name (\n";
        print $FHD "    id int";

        if ( $struct_hash->{$static_vec_type} ) {

            foreach $struct ( @{$struct_hash->{$static_vec_type}{order}} ) {

                print $FHD ",\n    $struct ".PreComp::Utilities::Type2Sql( $struct_hash->{$static_vec_type}{data}{$struct} );
            }
        }
        else {
            print $FHD ",\n    ".PreComp::Utilities::Type2Sql( $static_vec_short )." $static_vec_short";
        }

        print $FHD "\n);\n";

        PreComp::Utilities::CloseFile();

    }
}   

sub generate_table($) {
    my $obj_hash = shift;

    my $name = $obj_hash->{name};

    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::SqlRoot()."$name.table" );

    #print_licence_header( $FHD );

    print $FHD "create table $name (\n";
    print $FHD "    id int";

    foreach $key ( @{$obj_hash->{data}->{static_order}} ) {

        print $FHD ",\n    $key ".PreComp::Utilities::Type2Sql($obj_hash->{data}->{static}->{$key});
    }

    foreach $key ( @{$obj_hash->{data}->{sub_order}} ) {

        print $FHD ",\n    $key ".PreComp::Utilities::Type2Sql($obj_hash->{data}->{sub}->{$key});
    }

    print $FHD "\n";
    print $FHD ");\n";
    print $FHD "\n";


    PreComp::Utilities::CloseFile();
}

sub generate_vec_dummy_data($$$) {
    my $master_hash = shift;
    my $name = shift;
    my $struct_hash = shift;

    my $obj_hash = $master_hash->{$name};

    my $PI = 3.14;

    my $type_num = $obj_hash->{type_num};

    foreach $key ( keys %{$obj_hash->{data}->{static_vec}} ) {

        $static_vec_short = $key;
        $static_vec_short =~ s/\[.*\]//g;

        my $name = $obj_hash->{name}."_".$static_vec_short;

        my $static_vec_type = $obj_hash->{data}->{static_vec}->{$key};

        my $FHD = PreComp::Utilities::OpenFile( $ENV{APP_ROOT}."/data/default_set/"."$name.sql" );

        print $FHD "delete from $name;\n";
        print $FHD "insert into $name values ( $type_num";

        if ( $struct_hash->{$static_vec_type} ) {

            foreach $struct ( keys %{$struct_hash->{$static_vec_type}} ) {

                if ( $struct_hash->{$static_vec_type}->{$struct} =~ /int/ ) {
                    print $FHD ", 1";
                } 
                else {
                    print $FHD ", $PI";
                }
            }
        }
        else {
            print $FHD ", $PI";
        }

        print $FHD " );\n";

        PreComp::Utilities::CloseFile();

    }
}

1;
