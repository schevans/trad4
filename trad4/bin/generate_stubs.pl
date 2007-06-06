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
sub generate_viewer();
sub generate_struct();
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
my $struct_filename = "$name.h";
my $viewer = lower2camel_case ($name )."Viewer";
my $viewer_filename = "$viewer.cpp";

my $cap_name = $name;
$cap_name =~ s/^(\S+)/\U$1\E/g;
my $cap_base_name = $base_name;
$cap_base_name =~ s/^(\S+)/\U$1\E/g;

my $defs_root=$ENV{INSTANCE_ROOT}."/defs";
my $gen_root=$ENV{INSTANCE_ROOT}."/gen";
my $obj_root=$ENV{INSTANCE_ROOT}."/objects";

my ( @sub, @pub, @mem_pub, @static, @common, @header );

@common = ( "char* name",
            "int sleep_time" );

@header = ( "time_t last_published",
            "object_status status",
            "int pid",
            "int type" );

generate_all();

sub generate_all() {

    load_defs( "$defs_root/$name.t4" );

    generate_h_base( );

    if ( ! -f "$obj_root/$h_filename" ) {
        generate_h( );
    }

    generate_cpp_base();

    if ( ! -f "$obj_root/$cpp_filename" ) {
        generate_cpp();
    }

    generate_struct();

#    if ( ! $is_feed ) {
#        generate_viewer();
#    }

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
    print H_FILE "#include \"$cpp_base_name.h\"\n";
    print H_FILE "\n";
    print H_FILE "\n";
    print H_FILE "\n";
    print H_FILE "class $cpp_name : public $cpp_base_name {\n";
    print H_FILE "\n";
    print H_FILE "public:\n";
    print H_FILE "\n";
    print H_FILE "    $cpp_name( int id );\n";
    print H_FILE "    virtual ~$cpp_name() {}\n";
    print H_FILE "\n";

    if ( $is_feed ) {
        print H_FILE "    virtual bool LoadFeedData();\n";
    }
    else {
        print H_FILE "    virtual bool Calculate();\n";
    }
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

    if ( $is_feed ) {
        print H_FILE "#include \"FeedObject.h\"\n";
    }
    else {
        print H_FILE "#include \"CalcObject.h\"\n";
    }
        
    print H_FILE "#include \"common.h\"\n";
    print H_FILE "\n";

    print H_FILE "#include \"$name.h\"\n";

    foreach $tuple ( @sub ) {

        ( $type, $var ) = split / /, $tuple; 

        print H_FILE "#include \"$var.h\"\n";

    }

    print H_FILE "\n";
    print H_FILE "\n";

    if ( $is_feed ) {
        print H_FILE "class $cpp_base_name : public FeedObject {\n";
    }
    else {
        print H_FILE "class $cpp_base_name : public CalcObject {\n";
    }

    print H_FILE "\n";
    print H_FILE "public:\n";
    print H_FILE "\n";
    print H_FILE "    virtual ~$cpp_base_name() {}\n";
    print H_FILE "\n";
    print H_FILE "    virtual bool Load();\n";
    print H_FILE "    virtual int Type() { return ".type2num( $name )."; }\n";
    print H_FILE "    virtual int SizeOfStruct() { return sizeof($name); }\n";

    if ( ! $is_feed ) {

        print H_FILE "    virtual bool AttachToSubscriptions();\n";
        print H_FILE "    virtual bool Calculate() = 0;\n";
        print H_FILE "    virtual bool NeedRefresh();\n";
        print H_FILE "    virtual bool Save();\n";

    }

    print H_FILE "\n";

    print H_FILE "    std::string GetName() { return _name; }\n";
    print H_FILE "    void SetName( std::string name ) { _name = name; }\n";
    print H_FILE "\n";
    print H_FILE "    virtual int GetSleepTime() { return (($name*)_pub)->sleep_time; }\n";
    print H_FILE "    void SetSleepTime( int sleep_time ) { (($name*)_pub)->sleep_time = sleep_time; }\n";
    print H_FILE "\n";

    foreach $tuple ( @sub, @static, @pub ) {

        ( $type, $var ) = split / /, $tuple; 

        my $camel_var = lower2camel_case( $var );

        print H_FILE "    $type Get$camel_var() { return (($name*)_pub)->$var; }\n";
        print H_FILE "    void Set$camel_var( $type $var ) { (($name*)_pub)->$var = $var; }\n";
        print H_FILE "\n";

    }

    print H_FILE "protected:\n";

    foreach $tuple ( @sub ) {

        ( $type, $var ) = split / /, $tuple; 

        print H_FILE "\n    $var* _sub_$var;";

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

    if ( $is_feed ) {

        print CPP_FILE "bool $cpp_name\:\:LoadFeedData()\n";
        print CPP_FILE "{\n";
        print CPP_FILE "    cout << \"$cpp_name\:\:LoadFeedData()\" << endl;\n";
        print CPP_FILE "\n";
        print CPP_FILE "    Notify();\n";
        print CPP_FILE "    return true;\n";
        print CPP_FILE "}\n";
    
    }
    else {

        print CPP_FILE "bool $cpp_name\:\:Calculate()\n";
        print CPP_FILE "{\n";
        print CPP_FILE "    cout << \"$cpp_name\:\:Calculate()\" << endl;\n";
        print CPP_FILE "\n";
        print CPP_FILE "    Notify();\n";
        print CPP_FILE "    return true;\n";
        print CPP_FILE "}\n";

    }
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


    if ( ! $is_feed ) {

        print CPP_FILE "bool $cpp_base_name\:\:AttachToSubscriptions()\n";
        print CPP_FILE "{\n";

        if ( @sub ) {

            foreach $tuple ( @sub ) {

                ( $type, $var ) = split / /, $tuple; 

                print CPP_FILE "    _sub_$var = ($var*)AttachToSubscription( Get".lower2camel_case( $var )."() );\n";
                print CPP_FILE "\n";

            }

            print CPP_FILE "    if ( ";

            foreach $tuple ( @sub ) {

                ( $type, $var ) = split / /, $tuple; 

                print CPP_FILE "_sub_$var && ";

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

            print CPP_FILE "_sub_$var->last_published > *(int*)_pub || ";

        }

        print CPP_FILE " 0 );\n";

        print CPP_FILE "}\n";
        print CPP_FILE "\n";
        print CPP_FILE "bool $cpp_base_name\:\:Save()\n";
        print CPP_FILE "{\n";
        print CPP_FILE "    fstream save_file(_data_file_name.c_str(), ios::out);\n";
        print CPP_FILE "\n";
        print CPP_FILE "    save_file <<\n";

        foreach $tuple ( @common, @sub, @static, @pub ) {

            ( $type, $var ) = split / /, $tuple;

            my $camel_var = lower2camel_case( $var );

            print CPP_FILE "        Get$camel_var() << \",\" <<\n";

        }


        print CPP_FILE "    endl;\n";
        print CPP_FILE "\n";
        print CPP_FILE "    save_file.close();\n";
        print CPP_FILE "\n";
        print CPP_FILE "    return true;\n";
        print CPP_FILE "}\n";
        print CPP_FILE "\n";

    } 

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

    foreach $tuple ( @common, @sub, @static, @pub ) {

        ( $type, $var ) = split / /, $tuple;

        my $camel_var = lower2camel_case( $var );

        print CPP_FILE "    Set$camel_var( ".type2atoX($type)."(tok) );\n";
        print CPP_FILE "    tok = strtok( NULL, \",\" );\n";

    }

    print CPP_FILE "\n";
    print CPP_FILE "    load_file.close();\n";
    print CPP_FILE "\n";
    print CPP_FILE "    return true;\n";
    print CPP_FILE "}\n";
    print CPP_FILE "\n";

    close CPP_FILE;

}

sub generate_struct()
{
    open PUB_STRUCT_FILE, ">$gen_root/objects/$struct_filename" or die "Can't open $gen_root/objects/$h_filename for writing. Exiting";

    print PUB_STRUCT_FILE "\n";
    print PUB_STRUCT_FILE "#ifndef __$name"."__\n";
    print PUB_STRUCT_FILE "#define __$name"."__\n";
    print PUB_STRUCT_FILE "\n";
    print PUB_STRUCT_FILE "#include <sys/types.h>\n";
    print PUB_STRUCT_FILE "\n";
    print PUB_STRUCT_FILE "typedef struct {\n";

    print PUB_STRUCT_FILE "    // Header\n";

    foreach $tuple ( @header, @common ) {

        ( $type, $var ) = split / /, $tuple; 

        print PUB_STRUCT_FILE "    $type $var;\n";

    }

    print PUB_STRUCT_FILE "\n";
    print PUB_STRUCT_FILE "    // Sub\n";

    foreach $tuple ( @sub ) {

        ( $type, $var ) = split / /, $tuple; 

        print PUB_STRUCT_FILE "    int $var;\n";

    }

    print PUB_STRUCT_FILE "\n";
    print PUB_STRUCT_FILE "    // Static\n";

    foreach $tuple ( @static ) {

        ( $type, $var ) = split / /, $tuple; 

        print PUB_STRUCT_FILE "    $type $var;\n";

    }

    print PUB_STRUCT_FILE "\n";
    print PUB_STRUCT_FILE "    // Pub\n";

    foreach $tuple ( @pub, @mem_pub ) {

        ( $type, $var ) = split / /, $tuple; 

        print PUB_STRUCT_FILE "    $type $var;\n";

    }


    print PUB_STRUCT_FILE "} $name;\n";
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

            push @sub, trim( $line );

        }
        elsif ( $doing =~ /pub/ ) {

            $line =~ s/^ *//;
 
            if ( $line =~ '\[' ) {
                push @mem_pub, trim( $line );
            }
            else {
                push @pub, trim( $line );
            }
        }
        elsif ( $doing =~ /static/ ) {

            push @static, trim( $line );
        }
        else {
            die "Error";
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
    elsif ( $type =~ /string|char/ ) {
        return "";
    }
    elsif ( $type =~ /object_status/ ) {
        return "(object_status)atoi";
    }
    else {
        die "Odd type: $type";
    }
}

sub type2num($) {
    my $type = shift;
    
    if ( $type =~ /interest_rate_feed/ ) {
        return 1;
    }
    elsif ( $type =~ /discount_rate/ ) {
        return 2;
    }
    elsif ( $type =~ /bond/ ) {
        return 3;
    }
    elsif ( $type =~ /outright_trade/ ) {
        return 4
    }
    elsif ( $type =~ /repo_trade/ ) {
        return 5;
    }
    elsif ( $type =~ /fx_rate_feed/ ) {
        return 6;
    }
    else {
        die "Unknown type here";
    }
}
