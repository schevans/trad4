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

my @licence_header_array;

BEGIN {

    my $licence_header_file = "$ENV{APP_ROOT}/LICENCE_HEADER";
    
    if ( -f $licence_header_file ) {

        open LICENCE_HEADER_FILE, "$ENV{APP_ROOT}/LICENCE_HEADER";

        while ( $line = <LICENCE_HEADER_FILE> ) {

            push @licence_header_array, $line;
        }

        close LICENCE_HEADER_FILE;
    }
}

sub SetExitOnError($) {
    
    $exit_on_error = shift;
}

sub GenerateSpecs($) {
    my $master_hash = shift;

    if ( -f $ENV{SRC_DIR}."/specs.csv" ) {

        print "Warning: Generate specs: -s was specified but file already exists. Please move existing file to regenerate specs.csv.\n";
    }
    else {

        open SPECS_FILE, ">$ENV{SRC_DIR}/specs.csv";

        print SPECS_FILE "Object,Section,Name,Type,Given by\n";

        foreach $object ( keys %{$master_hash} ) {

            foreach $section ( "sub", "static", "static_vec", "pub", "pub_vec" ) {

                my $print_section = $section;
                $print_section =~ s/_vec//;

                foreach $var ( keys %{$master_hash->{$object}->{data}->{$section}} ) {

                    print SPECS_FILE "$object,$print_section,$var,$master_hash->{$object}->{data}->{$section}->{$var},";
            
                    if ( $section =~ /sub/ ) {

                        print SPECS_FILE "$var\n";
                    }
                    elsif ( $section =~ /static/ ) {

                        print SPECS_FILE "$object\n";
                    }
                    else {

                        print SPECS_FILE "write me\n";
                    }

                }
            }

        }
        
        close SPECS_FILE;
    }
}

sub Clean() {

    print "Cleaning $ENV{APP_ROOT}/gen/objects..\n";
    `rm -f $ENV{APP_ROOT}/gen/objects/*`; 

    print "Cleaning $ENV{APP_ROOT}/gen/sql..\n";
    `rm -f $ENV{APP_ROOT}/gen/sql/*`; 

    print "Cleaning $ENV{APP_ROOT}/data/default_set..\n";
    `rm -f $ENV{APP_ROOT}/data/default_set/*`; 

    print "Cleaning Makefiles..\n";
    `rm -f $ENV{APP_ROOT}/Makefile`;
    `rm -f $ENV{APP_ROOT}/lib/Makefile`;
    `rm -f $ENV{APP_ROOT}/objects/Makefile`;
}    

sub Validate($$$$$) {
    my $master_hash = shift;
    my $name = shift;
    my $struct_hash = shift;
    my $enum_hash = shift;
    my $alias_hash = shift;

    my $obj_hash = $master_hash->{$name};

    my $type_num =  $master_hash->{$name}->{type_num};

    foreach $key ( @{$obj_hash->{data}->{sub_order}} ) {

        if ( ! $master_hash->{$obj_hash->{data}->{sub}->{$key}} ) {

            print "Error: Type \'$name\' has a type \'".$obj_hash->{data}->{sub}->{$key}."\', which is not found in $ENV{SRC_DIR}.\n";
            ExitOnError();
        }
    }

    foreach $key ( @{$obj_hash->{data}->{sub_vec_order}} ) { 

        if ( ! $master_hash->{$obj_hash->{data}->{sub_vec}->{$key}} ) {

            print "Error: Type \'$name\' has a type \'".$obj_hash->{data}->{sub_vec}->{$key}."\', which is not found in $ENV{SRC_DIR}.\n";
            ExitOnError();
        }
    }

    foreach $key ( keys %{$master_hash} ) {

        if ( $key ne $name ) {

            if ( $master_hash->{$key}->{type_num} == $type_num ) {

                print "Error: Types \'$name\' and \'$key\' share the same type_num \'$type_num\' in object_types.t4s.\n";
                ExitOnError();
            }
        }
    }

    foreach $key ( keys %{$obj_hash->{data}} ) {

        if ( not $key =~ /_order/ ) {

            foreach $key2 ( keys %{$obj_hash->{data}->{$key}} ) {

                if ( not $obj_hash->{data}->{$key}->{$key2} =~ /int|double|float|long|char/ ) {

                    if ( exists $struct_hash->{$obj_hash->{data}->{$key}->{$key2}} ) {
        
                        next;
                    }

                    if ( exists $master_hash->{$obj_hash->{data}->{$key}->{$key2}} ) {

                        next;
                    }

                    if ( exists $enum_hash->{$obj_hash->{data}->{$key}->{$key2}} ) {

                        next;
                    }

                    if ( exists $alias_hash->{$obj_hash->{data}->{$key}->{$key2}} ) {

                        next;
                    }

                    if ( not $found_in_enums ) {

                        print "Error: Type \'$obj_hash->{data}->{$key}->{$key2}\', referred to in the $key section of $name.t4 not found. It's not:\n";
                        print "    a) an int, double or float\n";
                        print "    b) a structure, as defined in structures.t4s\n";
                        print "    c) an enum, as defined in enums.t4s\n";
                        print "    d) an alias, as defined in aliases.t4s\n";

                        ExitOnError();
                    }
                }

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


    my $file_type = $file;
    $file_type =~ s/^.*\.//g;

    my $comment_string;

    if ( $file =~ /Makefile/ ) {
        $comment_string = "#";
    }
    elsif ( $file_type =~ /h|c/ ) {
        $comment_string = "//";
    }
    elsif ( $file_type =~ /table|sql/ ) {
        $comment_string = "--";
    }
    else
    {
        print "Unknown file type $file_type\n";
    }
        
    open $current_file, ">$file.t4t" or die "Can't open file $file";

    foreach $line ( @licence_header_array ) {

        print $current_file "$comment_string $line";
    }

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

sub LoadAppConstants() {

    open APP_CONSTANTS_FILE, "$ENV{SRC_DIR}/constants.t4s" or die "Can't open $ENV{SRC_DIR}/constants.t4s for reading";

    my %constants_hash;
    my %expression_hash;
    my $constants;
    my $line;

    while ( $line = <APP_CONSTANTS_FILE> ) {

        chomp $line;

        $line =~ s/#.*//g;

        if ( !$line ) {
            next;
        }

        ( $name, $value ) = split /=/, $line;
        
        $name =~ s/^\s+//;
        $name =~ s/\s+$//;

        if ( exists $constants_hash->{$name} ) {

            print "Error: Multiple definitions of \'$name\' in constants.t4s\n";
            ExitOnError();

        }

        if ( !$value ) {

            print "Error: No value given for constant \'$name\' in constants.t4s\n";
            ExitOnError();
        }
        else {

            $value =~ s/^\s+//;
            $value =~ s/\s+$//;

            if ( $value =~ /[A-Za-z_]+/ ) {

                $expression_hash->{$name} = $value;
            }
            elsif ( $value =~ /^[0-9]+$/ or $value =~ /^[0-9]+\.[0-9]+$/ ) {

                $constants_hash->{$name} = $value;
            }
            else {

                print "Error: Can't evaluate expression \'$name = $value\' in constants.t4s.\n";
                ExitOnError();
            }
        }
    }

    close APP_CONSTANTS_FILE;

    foreach $expression_name ( keys %{$expression_hash} ) {

        $expression = $expression_hash->{$expression_name};

        foreach $constant ( keys %{$constants_hash} ) {

            $expression =~ s/$constant/$constants_hash->{$constant}/g;
        }

        $value = eval $expression;

        if ( ! $@ ) {

            $constants_hash->{$expression_name} = $value;
        }
    }

    foreach $expression_name ( keys %{$constants_hash} ) {

        if ( $constants_hash->{$expression_name} =~ /[A-Za-z_]+/ ) {


           if ( $constants_hash->{$constants_hash->{$expression_name}} =~ /^(\d+\.?\d*|\.\d+)$/ ) {

                $constants_hash->{$expression_name} = $constants_hash->{$constants_hash->{$expression_name}};
            } 
        }
    }

    foreach $expression_name ( keys %{$constants_hash} ) {
 
        if ( $constants_hash->{$expression_name} =~ /[A-Za-z_]+/ ) {

            print "NEW Error: Can't evaluate expression \'$expression_name = $constants_hash->{$expression_name}\' in constants.t4s.\n";
            ExitOnError();
        }
    }

    return $constants_hash;
}

sub LoadEnums() {

    open ENUMS_FILE, "$ENV{SRC_DIR}/enums.t4s" or die "Can't open $ENV{SRC_DIR}/enums.t4s for reading";

    my %enum_hash;
    my $enum;
    my $line;

    while ( $line = <ENUMS_FILE> ) {

        chomp $line;

        if ( !$line or $line =~ /#/ ) {
            next;
        }


        if ( $line =~ /^[a-z]/ ) {

            $enum = $line;
            next;
        }

        $line =~ s/^\s+//;
        $line =~ s/\s+$//;

        push @{$enum_hash{$enum}}, $line;
    }

    close ENUMS_FILE;

    return \%enum_hash;
}

sub LoadAliases() {

    open ALIAS_FILE, "$ENV{SRC_DIR}/aliases.t4s" or die "Can't open $ENV{SRC_DIR}/aliases.t4s for reading";

    my %alias_hash;

    my $line;
    my $counter = 0;

    while ( $line = <ALIAS_FILE> ) {

        chomp $line;

        $line =~ s/#.*//g;

        if ( !$line ) {
            next;
        }

        ( $name, $value ) = split /=/, $line;

        $name =~ s/^\s+//;
        $name =~ s/\s+$//;

        if ( exists $alias_hash->{$name} ) {

            print "Error: Multiple definitions of \'$name\' in aliass.t4s\n";
            ExitOnError();

        }

        if ( !$value ) {

            print "Error: No alias given for thing \'$name\' in aliases.t4s\n";
            ExitOnError();
        }
        else {

            $value =~ s/^\s+//;
            $value =~ s/\s+$//;

            $alias_hash->{$name} = $value;
        }
    }

    return $alias_hash;
}

sub LoadStructures() {

    open STRUCTURES_FILE, "$ENV{SRC_DIR}/structures.t4s" or die "Can't open $ENV{SRC_DIR}/structures.t4s for reading";

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

        if ( $line =~ /^[a-z]/i ) {

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

    if ( ! -f $ENV{SRC_DIR}."/object_types.t4s" ) {

        print "Error: File $ENV{SRC_DIR}/object_types.t4s not found.\n";
        ExitOnError();
    }

    open TYPES_FILE, "$ENV{SRC_DIR}/object_types.t4s" or die "Can't open $ENV{SRC_DIR}/object_types.t4s for reading";

    my $counter = 1;

    while ( $line = <TYPES_FILE> ) {

        chomp $line;

        if ( !$line or $line =~ /#/ ) {
            next;
        }

        if ( $line =~ /^\d+,\d+,\w+$/ ) {

            ( $num, $tier, $type ) = split /,/, $line;

            $num =~ s/^\s+//;
            $num =~ s/\s+$//;
            $tier =~ s/^\s+//;
            $tier =~ s/\s+$//;
            $type =~ s/^\s+//;
            $type =~ s/\s+$//;

            if ( -f $ENV{SRC_DIR}."/$type.t4" ) {

                if ( exists $master_hash{$type} ) {

                    print "Error: Two objects share the same name in object_types.t4s - $type.\n";
                    ExitOnError();
                }

                if ( $master_hash{$type}{type_num} ) {

                    print "Error: Two objects share the same type_id - $master_hash{$type} and $master_hash{$master_hash{$type}{type_num}}.\n";
                    ExitOnError();
                }

                $master_hash{$type}{type_num} = $num;
                $master_hash{$type}{tier} = $tier;
                $master_hash{$type}{name} = $type;

                $master_hash{$type}{data} = LoadDef( $type );

                $counter = $counter + 1;
            }
            else {

                print "Warning: Type \'$type\' referenced in object_types.t4s but not found in ".$ENV{SRC_DIR}.". Ignoring type.\n";
            }
        }
        else {

            print "Error: Malformed line in object_types.t4s, line $counter.\n";
            ExitOnError();
        }
    }

    foreach $type ( keys %master_hash ) {

        if ( defined $master_hash{$type}{data}{implements} ) {

            if ( defined $master_hash{$master_hash{$type}{data}{implements}} ) {

                my $temp = $master_hash{$master_hash{$type}{data}{implements}}{data};

                foreach $section ( "sub", "static", "pub" ) {

                    foreach $var ( keys %{$master_hash{$master_hash{$type}{data}{implements}}{data}{$section}} ) {
                    
                        $master_hash{$type}{data}{$section}{$var} = $master_hash{$master_hash{$type}{data}{implements}}{data}{$section}{$var};
                    }

                }

                foreach $section ( "sub_order", "static_order", "pub_order" ) {

                    foreach $var ( @{$master_hash{$master_hash{$type}{data}{implements}}{data}{$section}} ) {

                        push @{$master_hash{$type}{data}{$section}}, $var;

                    }
                }

            }
            else {

                print "Error: Type '$type' is defined as implementing '$master_hash{$type}{data}{implements}' which is an unknown type.\n";
                ExitOnError();
            }

        }
        else {

            $master_hash{$type}{data}{implements} = $type;
        }
    }

    if ( $counter == 0 ) {
        
        print "Error: object_types.t4s is empty.\n";
        ExitOnError();
    }

    my @file_list = `cd $ENV{SRC_DIR} && ls *.t4`;

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

    my $file = $ENV{SRC_DIR}."/$object.t4";

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

        if ( $line =~ /^implements \w/ ) {

            ( $ignore, $implements ) = split / /, $line;

            $object_hash{implements} = $implements;

            last;
        }

        if ( $line =~ /^sub$|^pub$|^static$/ ) {

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

sub PrintHeader($$$) {
    my $fh = shift;
    my $obj_hash_ref = shift;
    my $section = shift;

    foreach $key ( keys %{$obj_hash_ref->{data}->{$section}} ) {

        if ( $section =~ /sub/ ) {

            print $fh "    int $key;\n";
        }
        else {

            print $fh "    $obj_hash_ref->{data}->{$section}->{$key} $key;\n";
        }

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
    elsif ( $type =~ /long/ ) {
        return "std::atoi";
    }
    elsif ( $type =~ /char/ )
    {
        return "*";
    }
    else {

        if ( defined $alias_hash->{$type} ) {

            if ( $alias_hash->{$type} =~ /long int/ ) {

                return "std::atoi";
            }
            elsif ( $alias_hash->{$type} =~ /int/ ) {

                return "std::atoi";
            }
            else {

                print "Error: Unknown type \'$type\' in call to Type2atoX in trad4 internals.\n";
                ExitOnError();
            }
        }
        else {

            print "Error: Unknown type \'$type\' in call to Type2atoX in trad4 internals.\n";
            ExitOnError();
        }

    }
}

sub Type2Sql($) {
    my $type = shift;

    my $sql_type;

    if ( $type =~ 'double' ) {
        $sql_type = "float";
    }
    elsif ( $type =~ 'char' ) {
        $sql_type = "char";
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

