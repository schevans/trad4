# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#

package PreComp::Utilities;

use Data::Dumper;
use warnings;

my $current_file;
my $current_obj;

my %file_handle_map;

my $exit_on_error=1;

sub SetExitOnError($) {
    
    $exit_on_error = shift;
}

sub Clean() {

    print "Cleaning $ENV{APP_ROOT}/gen/objects..\n";
    `rm -f $ENV{APP_ROOT}/gen/objects/*`; 

    print "Cleaning $ENV{APP_ROOT}/gen/sql..\n";
    `rm -f $ENV{APP_ROOT}/gen/sql/*`; 

    print "Cleaning $ENV{APP_ROOT}/data/default_set..\n";
    `rm -f $ENV{APP_ROOT}/data/default_set/*`; 
}    

sub Validate($$) {
    my $master_hash = shift;
    my $name = shift;

    my $obj_hash = $master_hash->{$name};

    foreach $key ( keys %{$obj_hash->{data}->{sub}} ) {

        if ( ! $master_hash->{$key} ) {

            print "Error: Type \'$name\' has a sub type \'$key\', which is not found in $ENV{APP_ROOT}/defs.\n";
            ExitOnError();
        }
    }

    my $type_num =  $master_hash->{$name}->{type_num};

    foreach $key ( keys %{$master_hash} ) {

        if ( $key ne $name ) {

            if ( $master_hash->{$key}->{type_num} == $type_num ) {

                print "Error: Types \'$name\' and \'$key\' share the same type_num \'$type_num\' in object_types.t4s.\n";
                ExitOnError();
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

sub LoadStructures() {

    open STRUCTURES_FILE, "$ENV{APP_ROOT}/defs/structures.t4s" or die "Can't open $ENV{APP_ROOT}/defs/structures.t4s for reading";

    my %struct_hash;

    my $line;
    my $struct;
    my $struct_order;
    my $counter = 0;

    my ( $type, $var );

    while ( $line = <STRUCTURES_FILE> ) {

        $counter = $counter+1;

        chomp $line;

        if ( !$line or $line =~ /#/ ) {
            next;
        }

        if ( $line =~ /^[a-z]/ ) {

            $struct = $line;
        $struct_order = $line."_order";

            next;
        }

        $line =~ s/^\s+//;
        $line =~ s/\s+$//;

        ( $type, $var ) = split / /, $line;

        if ( !$type or !$var ) {

            print "Error: Malformed structures.t4s file, line $counter.\n";
            ExitOnError();
        }

        $struct_hash{$struct}{data}{$var} = $type;
        push @{$struct_hash{$struct}{order}}, $var;
    }

    close STRUCTURES_FILE;

    return \%struct_hash;
}

sub LoadDefs() {

    my %master_hash;

    if ( ! -f $ENV{APP_ROOT}."/defs/object_types.t4s" ) {

        print "Error: File $ENV{APP_ROOT}/defs/object_types.t4s not found.\n";
        ExitOnError();
    }

    open TYPES_FILE, "$ENV{APP_ROOT}/defs/object_types.t4s" or die "Can't open $ENV{APP_ROOT}/defs/object_types.t4s for reading";

    while ( $line = <TYPES_FILE> ) {

        chomp $line;

        if ( !$line or $line =~ /#/ ) {
            next;
        }

        ( $num, $tier, $type ) = split /,/, $line;

        if ( -f $ENV{APP_ROOT}."/defs/$type.t4" ) {

            $master_hash{$type}{tier} = $tier;

            if ( $master_hash{$type}{type_num} ) {

                print "Error: Two objects share the same type_id - $master_hash{$type} and $master_hash{$master_hash{$type}{type_num}}.\n";
                ExitOnError();
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
    my $file_section;
    my $hash_section;
    my $hash_section_order;
    my $counter = 0;

    my @order;

    my ( $type, $var );

    while ( $line = <FILE> ) {

        $counter = $counter+1;

        chomp $line;

        $line =~ s/^\s+//;
        $line =~ s/\s+$//;

        if ( !$line or $line =~ /#/ ) {
            next;
        }

        if ( $line =~ /sub|pub|static|feed_in|feed_out/ ) {

            $file_section = $line;
            $hash_section = $file_section;    
            $hash_section_order = $file_section;
            $object_hash->{$hash_section_order} = ();
            next;
        }

        ( $type, $var ) = split / /, $line;

        if ( !$type or !$var ) {

            print "Error: Malformed $object.t4 file, line $counter.\n";
            ExitOnError();
        }

        if ( $var =~ /\[.*]/ ) {
            $hash_section = $file_section."_vec";
            $hash_section_order = $file_section."_order";
        }
        elsif ( not $var =~ /\[.*]/ ) {
            $hash_section = $file_section;
            $hash_section_order = $file_section."_order";
        }

        $hash_section_order = $hash_section."_order";

        $object_hash{$hash_section}{$var} = $type;

        push @{$object_hash{$hash_section_order}}, $var;

    }

    close FILE;

    return \%object_hash;
}

sub HasStruct($$) {
    my $master_hash = shift;
    my $object = shift;



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

sub ExitOnError() {

    if ( $exit_on_error ) {

        exit 1;
    }

}
1;

