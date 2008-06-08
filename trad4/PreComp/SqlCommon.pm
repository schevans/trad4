
package PreComp::SqlCommon;

use PreComp::Utilities;
use PreComp::Constants;
use Data::Dumper;

sub generate_object_types($);

sub Generate($) {
    my $master_hash = shift;

    generate_object_types( $master_hash );
}

sub generate_object_types($) {
    my $master_hash = shift;
    
    my $obj_hash = $master_hash->{$name};

    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::SqlRoot()."object_types.sql" );

    #print_licence_header( $FHD );

    my $type;

    print $FHD "delete from object_types;\n";

    foreach $type ( %{$master_hash} ) {

        if ( $master_hash->{$type} ) {  # Hack alert - my hashes are a bit of a mess.
            print $FHD "insert into object_types values ( $master_hash->{$type}->{type_num}, \"$master_hash->{$type}->{name}\", $master_hash->{$type}->{tier}, 1 );\n";
        }
    }

    PreComp::Utilities::CloseFile();
}
1;
