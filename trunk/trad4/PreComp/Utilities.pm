
package PreComp::Utilities;

use Data::Dumper;
use warnings;

my $current_file;
my $current_obj;

my %file_handle_map;

sub OpenFile($) {
    my $file = shift;

    $current_obj = $file;

    open $current_file, ">$file.t4t" or die "Can't open file $file";

    return $current_file;

}

sub CloseFile() {

    close $current_file;

    $current_obj =~ s/\.t4t//;

    my $overwrite=1;

    if ( -f $current_obj ) {

        $overwrite = `diff $current_obj.t4t $current_obj`;
    }

    if ( $overwrite ) {
        `mv $current_obj.t4t $current_obj`;
    }
    else {
        `rm -f $current_obj.t4t`;
    }
}

sub LoadDefs() {

    open TYPES_FILE, "$ENV{INSTANCE_ROOT}/defs/object_types.t4s" or die "Can't open $ENV{INSTANCE_ROOT}/defs/object_types.t4s for reading";

    my %master_hash;

    while ( $line = <TYPES_FILE> ) {

        chomp $line;

        if ( !$line or $line =~ /#/ ) {
            next;
        }

        ( $num, $tier, $type ) = split /,/, $line;

        $master_hash{$type}{tier} = $tier;

        $master_hash{$type}{type_num} = $num;
        $master_hash{$type}{name} = $type;


        $master_hash{$type}{data} = LoadDef( $type );

    }

    return \%master_hash;

}

sub LoadDef($) {
    my $object = shift;

    my $file = $ENV{INSTANCE_ROOT}."/defs/$object.t4";

    open FILE, "$file" or die "Could not open $file for reading";

    my %object_hash;

    my $line;
    my $section;

    my ( $type, $var );

    while ( $line = <FILE> ) {

        chomp $line;

        if ( !$line or $line =~ /#/ ) {
            next;
        }

        $line =~ s/^\s+//;
        $line =~ s/\s+$//;

        if ( $line =~ /sub|pub|static|feed_in|feed_out/ ) {

            $section = $line;

            next;
        }

        ( $type, $var ) = split / /, $line;

        if ( $section =~ /static/ and  $var =~ /\[.*]/ ) {
            $section = "static_vec";
        }

        $object_hash{$section}{$var} = $type;
    }
    close FILE;

    return \%object_hash;
}

sub HasFeed($) {
    my $obj_hash = shift;

    return $obj_hash{feed_in} or  $obj_hash{feed_out};

}

sub PrintSection($$$) {
    my $fh = shift;
    my $section_ref = shift;
    my $indent = shift;

    foreach $key ( keys %{$section_ref} ) {

        print $fh "$indent$section_ref->{$key} $key;\n";

    }

}

sub Type2atoX($) {
    my $type = shift;

    if ( $type =~ /int/ ) {
        return "atoi";
    }
    elsif ( $type =~ /_enum/ ) {
        return "($type)atoi";
    }
    elsif ( $type =~ /double/ ) {
        return "std::atof";
    }
    else {
        die "Odd type: $type";
    }
}

sub Type2Sql($) {
    my $type = shift;

    my $sql_type;

    if ( $type =~ 'double' ) {
        $sql_type = "float";
    }
    else {
        $sql_type = "int";
    }

    return $sql_type;
}

1;

