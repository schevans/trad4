# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#

package PreComp::Utilities;

use Data::Dumper;
use warnings;

my $current_file;
my $current_obj;

my %file_handle_map;

sub Validate($$) {
    my $master_hash = shift;
    my $name = shift;

    my $obj_hash = $master_hash->{$name};

    foreach $key ( keys %{$obj_hash->{data}->{sub}} ) {

        if ( ! $master_hash->{$key} ) {

            print "Error: Type \'$name\' has a sub type \'$key\', which is not found in $ENV{APP_ROOT}/defs. Exiting.\n";
            return 0;
        }
    }

    my $type_num =  $master_hash->{$name}->{type_num};

    foreach $key ( keys %{$master_hash} ) {

        if ( $key ne $name ) {

            if ( $master_hash->{$key}->{type_num} == $type_num ) {

                print "Error: Types \'$name\' and \'$key\' share the same type_num \'$type_num\' in object_types.t4s. Exiting.\n";
                return 0;
            }
        }
    }

    return 1;
}

sub OpenFile($) {
    my $file = shift;

    $current_obj = $file;

    my @path_array = split /\//, $file;

    pop( @path_array );

    my $current_path = "";

    foreach $dir ( @path_array ) {

        $current_path = $current_path.$dir."/";

        if ( ! -d $current_path ) {

            print "Creating directory $current_path\n";

            mkdir( $current_path );
        }
    }

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

        if ( -f $current_obj ) {
            `cp $current_obj $current_obj.t4p`;
        }

        `mv $current_obj.t4t $current_obj`;
    }
    else {
        `rm -f $current_obj.t4t`;
    }
}

sub LoadDefs() {

    if ( ! -f $ENV{APP_ROOT}."/defs/object_types.t4s" ) {

        print "Error: File $ENV{APP_ROOT}/defs/object_types.t4s not found. Exiting.\n";
        exit(1);
    }

    open TYPES_FILE, "$ENV{APP_ROOT}/defs/object_types.t4s" or die "Can't open $ENV{APP_ROOT}/defs/object_types.t4s for reading";

    my %master_hash;

    while ( $line = <TYPES_FILE> ) {

        chomp $line;

        if ( !$line or $line =~ /#/ ) {
            next;
        }

        ( $num, $tier, $type ) = split /,/, $line;

        if ( -f $ENV{APP_ROOT}."/defs/$type.t4" ) {

            $master_hash{$type}{tier} = $tier;

            if ( $master_hash{$type}{type_num} ) {

                print "Error: Two objects share the same type_id - $master_hash{$type} and $master_hash{$master_hash{$type}{type_num}}. Exiting\n";
                exit(1);
            }

            $master_hash{$type}{type_num} = $num;
            $master_hash{$type}{name} = $type;

            $master_hash{$type}{data} = LoadDef( $type );
        }
        else {

            print "Warning: Type \'$type\' referenced in object_types.t4s but not found in ".$ENV{APP_ROOT}."/defs. Ignoring type.\n";
        }
    }

    my @file_list = `cd $ENV{APP_ROOT}/defs && ls *.t4`;

    foreach $file ( @file_list  ) {

        chomp ( $file );

        $file =~ s/\.t4//g;

        if ( ! exists($master_hash{$file} )) {

            print "Warning: Type \'$file\' has a $file.t4 file but is not referenced in object_types.t4s. Ignoring type.\n";
        }
    }

    return \%master_hash;

}

sub LoadDef($) {
    my $object = shift;

    my $file = $ENV{APP_ROOT}."/defs/$object.t4";

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

