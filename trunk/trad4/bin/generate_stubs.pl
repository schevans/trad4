#!/usr/bin/perl

# Copyright Steve Evans 2007
# steve@topaz.myzen.co.uk

use warnings;

if ( !$ENV{TRAD4_ROOT} ) {

    print "TRAD4_ROOT not set. Exiting\n";
    exit 1;
}

if ( @ARGV != 1 ) {
    print "usage: generate_stubs.pl <object_name>\n";
    exit 1;
}

my $name = $ARGV[0];

my $is_feed=0;

if ( $name =~ /feed/ ) {
    $is_feed = 1;
}

sub generate_cpp_base();
sub generate_h_base();
sub generate_pub_struct();
sub load_defs($);
sub generate_all();
sub trim($);
sub cpp2sql_type($);
sub lower2camel_case($);
sub type2atoX($);

my $base_name = $name."_base";
my $cpp_name = lower2camel_case ($name );
my $cpp_base_name = lower2camel_case ($name )."Base";
my $cpp_filename = lower2camel_case ($name ).".cpp";
my $cpp_base_filename = lower2camel_case ($name )."Base.cpp";
my $h_filename = "$cpp_name".".h";
my $h_base_filename = "$cpp_base_name".".h";
my $table_filename = "$name.table";
my $pub_struct = "pub_".$name;
my $pub_struct_filename = "pub_$name.h";

my $cap_name = $name;
$cap_name =~ s/^(\S+)/\U$1\E/g;
my $cap_base_name = $base_name;
$cap_base_name =~ s/^(\S+)/\U$1\E/g;

my $defs_root=$ENV{INSTANCE_ROOT}."/defs";
my $gen_root=$ENV{INSTANCE_ROOT}."/gen";
my $obj_root=$ENV{INSTANCE_ROOT}."/objects";

my ( @sub, @pub, @mem_pub, @static, @common );

@common = ( "std::string _name",
            "int _sleep_time",
            "int _log_level" );

generate_all();

sub generate_all() {

    load_defs( "$defs_root/$name.t4" );

    if ( $is_feed == 0 ) {

        generate_h_base( );

        if ( ! -f "$obj_root/$h_filename" ) {
            generate_h( );
        }

        generate_cpp_base();

        if ( ! -f "$obj_root/$cpp_filename" ) {
            generate_cpp();
        }

    }

    generate_pub_struct();

    if ( $is_feed ) {
        print "Generated $name\n";
    }
    else {
        print "Generated $cpp_name\n";
    }
    

}


####################



####################

sub generate_h() {

    my $tuple;
    my ( $var, $type );

    open H_FILE, ">$obj_root/$h_filename" or die "Can't open $obj_root/$h_filename for writing. Exiting";
    print H_FILE "#ifndef __$cap_name"."__\n";
    print H_FILE "#define __$cap_name"."__\n";
    print H_FILE "\n";
    print H_FILE "#include \"Object.h\"\n";
    print H_FILE "#include \"$cpp_base_name.h\"\n";
#    print H_FILE "#include \"common.h\"\n";
    print H_FILE "\n";
    print H_FILE "\n";
    print H_FILE "\n";
    print H_FILE "class $cpp_name : public $cpp_base_name {\n";
    print H_FILE "\n";
    print H_FILE "public:\n";
    print H_FILE "\n";
    print H_FILE "    $cpp_name( int id );\n";
    print H_FILE "    virtual ~$cpp_name();\n";
    print H_FILE "\n";
    print H_FILE "    virtual bool Calculate();\n";
    print H_FILE "\n";
    print H_FILE "};\n";
    print H_FILE "\n";
    print H_FILE "#endif\n";
    print H_FILE "\n";

    close H_FILE;

}


sub generate_h_base()
{

    my $tuple;
    my ( $var, $type );

    open H_FILE, ">$gen_root/objects/$h_base_filename" or die "Can't open $gen_root/objects/$h_base_filename for writing. Exiting";
    print H_FILE "#ifndef __$cap_base_name"."__\n";
    print H_FILE "#define __$cap_base_name"."__\n";
    print H_FILE "\n";
    print H_FILE "#include \"Object.h\"\n";
    print H_FILE "#include \"common.h\"\n";
    print H_FILE "\n";

    print H_FILE "#include \"pub_$name.h\"\n";

    foreach $tuple ( @sub ) {

        ( $type, $var ) = split / /, $tuple; 

        print H_FILE "#include \"pub_$type.h\"\n";

    }

    print H_FILE "\n";
    print H_FILE "\n";
    print H_FILE "class $cpp_base_name : public Object {\n";
    print H_FILE "\n";
    print H_FILE "public:\n";
    print H_FILE "\n";
    print H_FILE "    virtual ~$cpp_base_name() {}\n";
    print H_FILE "\n";
    print H_FILE "    virtual bool AttachToSubscriptions();\n";
    print H_FILE "    virtual void SetObjectStatus( object_status status );\n";
    print H_FILE "    virtual bool Calculate() = 0;\n";
    print H_FILE "    virtual bool NeedRefresh();\n";
    print H_FILE "    virtual bool Save();\n";
    print H_FILE "    virtual bool Load();\n";
    print H_FILE "    virtual int Type();\n";
    print H_FILE "\n";

    foreach $tuple ( @pub ) {

        ( $type, $var ) = split / /, $tuple; 

        my $camel_var = lower2camel_case( $var );

        print H_FILE "    $type GetPub$camel_var() { return ((pub_$name*)_pub)->$var; }\n";
        print H_FILE "    void SetPub$camel_var( $type $var ) { ((pub_$name*)_pub)->$var = $var; }\n";
        print H_FILE "\n";

    }

    print H_FILE "\n";
    print H_FILE "\n";
    print H_FILE "protected:\n";
    print H_FILE "\n";
    print H_FILE "    // Static\n";

    foreach $tuple ( @static ) {

        print H_FILE "    $tuple;\n";

    }

    print H_FILE "\n";
    print H_FILE "    // Sub";

    foreach $tuple ( @sub ) {

        ( $type, $var ) = split / /, $tuple; 

        print H_FILE "\n    pub_$type* _sub$var;";
        print H_FILE "\n    int $var;";

    }

    print H_FILE "\n";
    print H_FILE "};\n";
    print H_FILE "\n";
    print H_FILE "#endif\n";

    close H_FILE;
}

sub generate_cpp() {

    my $tuple;
    my ( $var, $type );

    open CPP_FILE, ">$obj_root/$cpp_filename" or die "Can't open $obj_root/$cpp_filename for writing. Exiting";

    print CPP_FILE "#include <sys/ipc.h>\n";
    print CPP_FILE "#include <sys/shm.h>\n";
    print CPP_FILE "#include <iostream>\n";
    print CPP_FILE "\n";
    print CPP_FILE "#include \"$h_filename\"\n";
    print CPP_FILE "\n";
    print CPP_FILE "using namespace std;\n";
    print CPP_FILE "\n";
    print CPP_FILE "$cpp_name\:\:$cpp_name( int id )\n";
    print CPP_FILE "{\n";
    print CPP_FILE "    cout << \"$cpp_name\:\:$cpp_name: \"<< id << endl;\n";
    print CPP_FILE "\n";
    print CPP_FILE "    _pub = (pub_$name*)CreateShmem(sizeof(pub_$name));\n";
    print CPP_FILE "\n";
    print CPP_FILE "    Init( id );\n";
    print CPP_FILE "}\n";
    print CPP_FILE "\n";
    print CPP_FILE "bool $cpp_name\:\:Calculate()\n";
    print CPP_FILE "{\n";
    print CPP_FILE "    return true;\n";
    print CPP_FILE "}\n";
    print CPP_FILE "\n";

    close CPP_FILE;
}


sub generate_cpp_base() {

    my $tuple;
    my ( $var, $type );

    open CPP_FILE, ">$gen_root/objects/$cpp_base_filename" or die "Can't open $gen_root/objects/$cpp_base_filename for writing. Exiting";

    print CPP_FILE "#include <sys/ipc.h>\n";
    print CPP_FILE "#include <sys/shm.h>\n";
    print CPP_FILE "#include <iostream>\n";
    print CPP_FILE "#include <fstream>\n";
    print CPP_FILE "\n";
    print CPP_FILE "#include \"$h_base_filename\"\n";
    print CPP_FILE "\n";
    print CPP_FILE "using namespace std;\n";
    print CPP_FILE "\n";
    print CPP_FILE "bool $cpp_base_name\:\:AttachToSubscriptions()\n";
    print CPP_FILE "{\n";

    if ( @sub ) {

        foreach $tuple ( @sub ) {

            ( $type, $var ) = split / /, $tuple; 

            print CPP_FILE "    _sub$var = (pub_$type*)AttachToSubscription( $var );\n";
            print CPP_FILE "\n";

        }

        print CPP_FILE "    if ( ";

        foreach $tuple ( @sub ) {

            ( $type, $var ) = split / /, $tuple; 

            print CPP_FILE "_sub$var && ";

        }

        print CPP_FILE " 1 )\n";
        print CPP_FILE "        return true;\n";
        print CPP_FILE "    else\n";
        print CPP_FILE "        return false;\n";
        print CPP_FILE "\n";

    }
    else {
        print CPP_FILE "        return true;\n";
    }


    print CPP_FILE "}\n";
    print CPP_FILE "\n";
    print CPP_FILE "bool $cpp_base_name\:\:NeedRefresh()\n";
    print CPP_FILE "{\n";
  
    print CPP_FILE "    return ( ";

    foreach $tuple ( @sub ) {

        ( $type, $var ) = split / /, $tuple; 

        print CPP_FILE "_sub$var->last_published > *(int*)_pub || ";

    }

    print CPP_FILE " 0 );\n";

    print CPP_FILE "}\n";
    print CPP_FILE "\n";
    print CPP_FILE "bool $cpp_base_name\:\:Save()\n";
    print CPP_FILE "{\n";
    print CPP_FILE "    fstream save_file(_data_file_name.c_str(), ios::out);\n";
    print CPP_FILE "\n";
    print CPP_FILE "    save_file <<\n";

    foreach $tuple ( @common, @sub, @static ) {

        ( $type, $var ) = split / /, $tuple; 

        print CPP_FILE "        $var << \",\" <<\n";

    }

    foreach $tuple ( @pub ) {

        ( $type, $var ) = split / /, $tuple; 

        print CPP_FILE "        ((pub_$name*)_pub)->$var << \",\" <<\n";

    }


    print CPP_FILE "    endl;\n";
    print CPP_FILE "\n";
    print CPP_FILE "    save_file.close();\n";
    print CPP_FILE "\n";
    print CPP_FILE "    return true;\n";
    print CPP_FILE "}\n";
    print CPP_FILE "\n";
    print CPP_FILE "bool $cpp_base_name\:\:Load()\n";
    print CPP_FILE "{\n";
    print CPP_FILE "    fstream load_file(_data_file_name.c_str(), ios::in);\n";
    print CPP_FILE "\n";
    print CPP_FILE "    char record[MAX_OB_FILE_LEN];\n";
    print CPP_FILE "\n";
    print CPP_FILE "    load_file >> record;\n";
    print CPP_FILE "\n";
    print CPP_FILE "    cout << record << endl;\n";
    print CPP_FILE "\n";
    print CPP_FILE "    char* tok;\n";
    print CPP_FILE "\n";
    print CPP_FILE "    tok = strtok( record, \",\" );\n";
    print CPP_FILE "\n";

    foreach $tuple ( @common, @sub, @static ) {

        ( $type, $var ) = split / /, $tuple; 

        print CPP_FILE "    $var = ".type2atoX($type)."(tok);\n"; 
        print CPP_FILE "    tok = strtok( NULL, \",\" );\n";
    }

    foreach $tuple ( @pub ) {

        ( $type, $var ) = split / /, $tuple; 

        print CPP_FILE "    ((pub_$name*)_pub)->$var = ".type2atoX($type)."(tok);\n";

    }


    print CPP_FILE "\n";
    print CPP_FILE "\n";
    print CPP_FILE "\n";
    print CPP_FILE "\n";
    print CPP_FILE "    load_file.close();\n";
    print CPP_FILE "\n";
    print CPP_FILE "    return true;\n";
    print CPP_FILE "}\n";
    print CPP_FILE "\n";
    print CPP_FILE "void $cpp_base_name\:\:SetObjectStatus( object_status status )\n";
    print CPP_FILE "{\n";
    print CPP_FILE "    ((pub_$name*)_pub)->status = status;\n";
    print CPP_FILE "}\n";
    print CPP_FILE "\n";
    print CPP_FILE "int $cpp_base_name\:\:Type()\n";
    print CPP_FILE "{\n";

    if ( $name =~ "interest_rate_feed" ) {
        print CPP_FILE "    return 1;\n";
    }
    elsif ( $name =~ "discount_rate" ) {
        print CPP_FILE "    return 2;\n";
    }
    elsif (  $name =~ "bond" ) {
        print CPP_FILE "    return 3;\n";
    }
    else {
        die "Type $type not catered for here";
    }
    print CPP_FILE "}\n";
    print CPP_FILE "\n";

    close CPP_FILE;

}

sub generate_pub_struct()
{
    open PUB_STRUCT_FILE, ">$gen_root/objects/$pub_struct_filename" or die "Can't open $gen_root/objects/$h_filename for writing. Exiting";

    print PUB_STRUCT_FILE "\n";
    print PUB_STRUCT_FILE "#ifndef __$pub_struct"."__\n";
    print PUB_STRUCT_FILE "#define __$pub_struct"."__\n";
    print PUB_STRUCT_FILE "\n";
    print PUB_STRUCT_FILE "#include <sys/types.h>\n";
    print PUB_STRUCT_FILE "\n";
    print PUB_STRUCT_FILE "typedef struct {\n";
    print PUB_STRUCT_FILE "    time_t last_published;\n";
    print PUB_STRUCT_FILE "    object_status status;\n";
    print PUB_STRUCT_FILE "    int pid;\n";

    foreach $tuple ( @pub, @mem_pub ) {

        ( $type, $var ) = split / /, $tuple; 

        print PUB_STRUCT_FILE "    $type $var;\n";

    }

    print PUB_STRUCT_FILE "} pub_$name;\n";
    print PUB_STRUCT_FILE "\n";
    print PUB_STRUCT_FILE "#endif\n";

    close PUB_STRUCT_FILE;
}

sub load_defs($) {
    my $file = shift;

    open FILE, "$file" or die "Could not open $file";


    my $line;

    my $doing;



    while ( $line = <FILE> ) {

        chomp $line;

        if ( !$line ) {
            next;
        }

        if ( $line =~ /sub|pub|static/ ) {

            $doing = $line;
            next;
        }

        if ( $doing =~ /sub/ ) {

            $line = trim( $line );
            $line =~ s/ / _/;
            push @sub, $line;

        }
        elsif ( $doing =~ /pub/ ) {

            $line =~ s/^ *//;
 
            if ( $line =~ '\[' ) {
                push @mem_pub, $line;
            }
            else {
                push @pub, $line;
            }
        }
        elsif ( $doing =~ /static/ ) {

            $line =~ s/^ *//;
            $line =~ s/ / _/;
            push @static, $line;
        }
        else {
            print "Error\n";
            exit 0;
        }

    }

    close FILE;

}

sub trim($) {
    my $str = shift;

    $str =~ s/\s+$//;
    $str =~ s/^\s+//;

    return $str;
}


sub cpp2sql_type($) {
    my $cpp_type = shift;

    my $sql_type;

    if ( $cpp_type =~ 'double' ) {
        $sql_type = "float";
    }
    else {
        $sql_type = "int";
    } 
    
    return $sql_type;
}

sub lower2camel_case($) {
    my $lower_case = shift;

    my $camel_case = $lower_case;
    $camel_case =~ s/_/ /g;
    $camel_case =~ s/([A-Za-z])([A-Za-z]+)/\U$1\E\L$2\E/g;
    $camel_case =~ s/ //g;

    return $camel_case; 
}

sub lower2label($) {
    my $lower_case = shift;

    my $label = $lower_case;
    $label =~ s/_/ /g;
    $label =~ s/([A-Za-z])([A-Za-z]+)/\U$1\E\L$2\E/g;

    return $label;
}

sub type2atoX($) {
    my $type = shift;

    if ( $type =~ /int/ ) {
        return "atoi";
    }
    elsif ( $type =~ /double/ ) {
        return "atof";
    }
    elsif ( $type =~ /string/ ) {
        return "";
    }
    elsif ( $type =~ /object_status/ ) {
        return "(object_status)atoi";
    }
    else {
        return "atoi";
    }
}

