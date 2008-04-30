
package PreComp::Sql;

use PreComp::Utilities;
use PreComp::Constants;
use Data::Dumper;

sub Generate($) {
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
    print $FHD ")\n";
    print $FHD "\n";


    PreComp::Utilities::CloseFile();
}

1;
