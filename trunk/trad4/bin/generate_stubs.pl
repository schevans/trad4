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
my $is_vec=0;

if ( $name =~ /feed/ ) {
    $is_feed = 1;
}
elsif ( $name =~ /vec/ ) {
    $is_vec = 1;
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

my ( @sub, @pub, @mem_pub, @static, @static_vec, @common, @header );

@common = ( "char name[OBJECT_NAME_LEN]",
            "int sleep_time" );

@header = ( "time_t last_published",
            "object_status status",
            "int pid",
            "int type" );

open TYPES_FILE, "$ENV{INSTANCE_ROOT}/defs/object_types.t4s" or die "Can't open $ENV{INSTANCE_ROOT}/defs/object_types.t4s for reading";

my ( $line, $num, $type );
my %types_map;
while ( $line = <TYPES_FILE> ) {

    chomp $line;
    ( $num, $type ) = split /,/, $line;
    $types_map{$type} = $num;
}

close TYPES_FILE;


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
    
    if ( ! $is_vec ) {
        generate_viewer();
    }

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
    print H_FILE "    $cpp_name( int id ) { _id = id; }\n";
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

    if ( $is_vec ) {
        print H_FILE "#include <vector>\n";
        print H_FILE "#include <sstream>\n";
        print H_FILE "\n";
    }

    if ( $is_feed ) {
        print H_FILE "#include \"FeedObject.h\"\n";
    }
    else {
        if ( $is_vec ) {
            print H_FILE "#include \"CalcObjectVec.h\"\n";
        }
        else {
            print H_FILE "#include \"CalcObject.h\"\n";
        }
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
        if ( $is_vec ) {
            print H_FILE "class $cpp_base_name : public CalcObjectVec {\n";
        }
        else {
            print H_FILE "class $cpp_base_name : public CalcObject {\n";
        }
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
        print H_FILE "    virtual bool CheckSubscriptions();\n";
        print H_FILE "    virtual bool Calculate() = 0;\n";
        print H_FILE "    virtual bool NeedRefresh();\n";
        print H_FILE "    virtual bool Save();\n";

    }

    print H_FILE "\n";

    print H_FILE "    std::string GetName() { return (($name*)_pub)->name; }\n";
    print H_FILE "    void SetName( std::string name );\n";
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
        print CPP_FILE "    Load();\n";
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
        print CPP_FILE "bool $cpp_base_name\:\:CheckSubscriptions()\n";
        print CPP_FILE "{\n";

        if ( @sub ) {

            print CPP_FILE "    if ( ";

            foreach $tuple ( @sub ) {

                ( $type, $var ) = split / /, $tuple; 

                print CPP_FILE "_sub_$var->status != RUNNING || ";

            }

            print CPP_FILE " 0 )\n";
            print CPP_FILE "        SetStatus(STALE);\n";

            print CPP_FILE "    else if ( ";

            foreach $tuple ( @sub ) {

                ( $type, $var ) = split / /, $tuple; 

                print CPP_FILE "_sub_$var->status == RUNNING && ";

            }

            print CPP_FILE " 1 )\n";

            print CPP_FILE "        SetStatus(RUNNING);\n";
        }

        print CPP_FILE "\n";
        print CPP_FILE "    return true;\n";
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

        print CPP_FILE "        GetName() << \",\" <<\n";
        print CPP_FILE "        GetSleepTime() << \",\" <<\n";

        foreach $tuple ( @sub, @static, @pub ) {

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
    print CPP_FILE "    if ( load_file.is_open() )\n";
    print CPP_FILE "    {\n";
    print CPP_FILE "\n";
    print CPP_FILE "        char record[MAX_OB_FILE_LEN];\n";
    print CPP_FILE "\n";
    print CPP_FILE "        load_file >> record;\n";
    print CPP_FILE "\n";
    print CPP_FILE "        cout << record << endl;\n";
    print CPP_FILE "\n";
    print CPP_FILE "        char* tok;\n";
    print CPP_FILE "\n";
    print CPP_FILE "        tok = strtok( record, \",\" );\n";

    print CPP_FILE "        SetName( (tok) );\n";
    print CPP_FILE "        tok = strtok( NULL, \",\" );\n";

    print CPP_FILE "        SetSleepTime( atoi(tok) );\n";
    print CPP_FILE "        tok = strtok( NULL, \",\" );\n";

    foreach $tuple ( @sub, @static, @pub ) {

        ( $type, $var ) = split / /, $tuple;

        my $camel_var = lower2camel_case( $var );

        print CPP_FILE "        Set$camel_var( ".type2atoX($type)."(tok) );\n";
        print CPP_FILE "        tok = strtok( NULL, \",\" );\n";

    }
    print CPP_FILE "\n";
    print CPP_FILE "        load_file.close();\n";

    print CPP_FILE "\n";
    print CPP_FILE "    }\n";
    print CPP_FILE "    else\n";
    print CPP_FILE "    {\n";
    print CPP_FILE "        cout << \"Could not open file \" << _data_file_name << \". Exiting.\" << endl;\n";
    print CPP_FILE "        ExitOnError();\n";
    print CPP_FILE "    }\n";
    print CPP_FILE "\n";

    if ( $is_vec ) {

        
        print CPP_FILE "    ostringstream stream;\n";
        print CPP_FILE "    stream << _data_dir << _id << \".\" << Type() << \".t4v\";\n";
        print CPP_FILE "\n";
        print CPP_FILE "    string temp( stream.str() );\n";
        print CPP_FILE "\n";
        print CPP_FILE "    fstream load_file_vec( temp.c_str(), ios::in);\n";
        print CPP_FILE "\n";
        print CPP_FILE "    if ( load_file_vec.is_open() )\n";
        print CPP_FILE "    {\n";
        print CPP_FILE "        char record[MAX_OB_FILE_LEN];\n";
        print CPP_FILE "\n";
        print CPP_FILE "        while( load_file_vec >> record )\n";
        print CPP_FILE "        {\n";
        print CPP_FILE "            _element_ids.push_back( atoi( record ));\n";
        print CPP_FILE "        }\n";
        print CPP_FILE "\n";
        print CPP_FILE "    }\n";
        print CPP_FILE "    else\n";
        print CPP_FILE "    {\n";
        print CPP_FILE "        cout << \"Could not open file \" << temp << \". Exiting.\" << endl;\n";
        print CPP_FILE "        ExitOnError();\n";
        print CPP_FILE "    }\n";
        print CPP_FILE "\n";

    }

    print CPP_FILE "\n";
    print CPP_FILE "    return true;\n";
    print CPP_FILE "}\n";
    print CPP_FILE "\n";
    print CPP_FILE "void $cpp_base_name\:\:SetName( std::string name )\n";
    print CPP_FILE "{\n";
    print CPP_FILE "    for ( int i = 0 ; i < OBJECT_NAME_LEN ; i++ )\n";
    print CPP_FILE "    {\n";
    print CPP_FILE "        (($name*)_pub)->name[i] = name[i];\n";
    print CPP_FILE "    }\n";
    print CPP_FILE "}\n";

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
    print PUB_STRUCT_FILE "#include \"trad4.h\"\n";
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

sub generate_viewer()
{
    open FILE, ">$gen_root/viewer/$viewer_filename" or die "Can't open $gen_root/viewer/$viewer_filename for writing. Exiting";

    my $sub_name = "_sub_$name"."s";

    print FILE "\n";
    print FILE "\n";
    print FILE "#include <gtkmm.h>\n";
    print FILE "#include <iostream>\n";
    print FILE "#include <vector>\n";
    print FILE "#include <map>\n";
    print FILE "#include <sstream>\n";
    print FILE "#include <fstream>\n";
    print FILE "#include <sys/shm.h>\n";
    print FILE "\n";
    print FILE "#include \"common.h\"\n";
    print FILE "#include \"$name.h\"\n";
    print FILE "\n";
    print FILE "using namespace std;\n";
    print FILE "\n";
    print FILE "#include \"trad4.h\"\n";
    print FILE "\n";
    print FILE "class $viewer : public Gtk::Window\n";
    print FILE "{\n";
    print FILE "\n";
    print FILE "public:\n";
    print FILE "\n";
    print FILE "    $viewer();\n";
    print FILE "    virtual ~$viewer();\n";
    print FILE "\n";
    print FILE "protected:\n";
    print FILE "\n";
    print FILE "    bool Refresh( int num );\n";
    print FILE "\n";
    print FILE "    class ModelColumns : public Gtk::TreeModel::ColumnRecord\n";
    print FILE "    {\n";
    print FILE "        public:\n";
    print FILE "\n";
    print FILE "        ModelColumns()\n";
    print FILE "        {\n";

    print FILE "            add(_col_id);\n";
    print FILE "            add(_col_name);\n";
    print FILE "            add(_col_sleep_time);\n";
    print FILE "            add(_col_last_published);\n";
    print FILE "            add(_col_status);\n";
    print FILE "            add(_col_pid);\n";

    foreach $tuple ( @sub, @static, @pub ) {

        ( $type, $var ) = split / /, $tuple;

        print FILE "            add(_col_$var);\n";

    }

    print FILE "        }\n";
    print FILE "\n";

    print FILE "        Gtk::TreeModelColumn<int> _col_id;\n";
    print FILE "        Gtk::TreeModelColumn<Glib::ustring> _col_name;\n";
    print FILE "        Gtk::TreeModelColumn<int> _col_sleep_time;\n";
    print FILE "        Gtk::TreeModelColumn<int> _col_last_published;\n";
    print FILE "        Gtk::TreeModelColumn<Glib::ustring> _col_status;\n";
    print FILE "        Gtk::TreeModelColumn<int> _col_pid;\n";

    foreach $tuple ( @sub, @static, @pub ) {

        ( $type, $var ) = split / /, $tuple;

        print FILE "        Gtk::TreeModelColumn<$type> _col_$var;\n";

    }

    print FILE "    };\n";
    print FILE "\n";
    print FILE "    ModelColumns _columns;\n";
    print FILE "\n";
    print FILE "    Gtk::VBox _vBox;\n";
    print FILE "\n";
    print FILE "    Gtk::ScrolledWindow _scrolledWindow;\n";
    print FILE "    Gtk::TreeView _treeView;\n";
    print FILE "    Glib::RefPtr<Gtk::ListStore> _refTreeModel;\n";
    print FILE "\n";
    print FILE "    vector<Gtk::TreeModel::Row> my_rows;\n";
    print FILE "    vector<Glib::ustring> _status_vec;\n";
    print FILE "\n";
    print FILE "    vector<$name*> $sub_name;\n";
    print FILE "\n";
    print FILE "    obj_loc* _obj_loc;\n";
    print FILE "\n";
    print FILE "    std::string TimeToString( time_t time );\n";
    print FILE "};\n";
    print FILE "\n";
    print FILE "$viewer\:\:$viewer()\n";
    print FILE "{\n";
    print FILE "\n";
    print FILE "    set_title(\"$viewer\");\n";
    print FILE "    set_border_width(5);\n";
    print FILE "    set_default_size(650, 400);\n";
    print FILE "\n";
    print FILE "    add(_vBox);\n";
    print FILE "\n";
    print FILE "    sigc::slot<bool> my_slot = sigc::bind(sigc::mem_fun(*this, \&".$viewer."::Refresh), 0);\n";
    print FILE "\n";
    print FILE "    sigc::connection conn = Glib::signal_timeout().connect(my_slot, 1000);\n";
    print FILE "\n";
    print FILE "    _scrolledWindow.add(_treeView);\n";
    print FILE "\n";
    print FILE "    _scrolledWindow.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC);\n";
    print FILE "\n";
    print FILE "    _vBox.pack_start(_scrolledWindow);\n";
    print FILE "\n";
    print FILE "\n";
    print FILE "    _refTreeModel = Gtk::ListStore::create(_columns);\n";
    print FILE "    _treeView.set_model(_refTreeModel);\n";
    print FILE "\n";
    print FILE "    Gtk::TreeModel::Row row;\n";
    print FILE "\n";
    print FILE "    char* obj_loc_file_name = getenv( \"OBJ_LOC_FILE\" );\n";
    print FILE "\n";
    print FILE "    if ( obj_loc_file_name == NULL )\n";
    print FILE "    {\n";
    print FILE "        cout << \"OBJ_LOC_FILE not set. Exiting\" << endl;\n";
    print FILE "        exit(1);\n";
    print FILE "    }\n";
    print FILE "\n";
    print FILE "    fstream obj_loc_file(obj_loc_file_name, ios::in);\n";
    print FILE "\n";
    print FILE "    if ( ! obj_loc_file.is_open() )\n";
    print FILE "    {\n";
    print FILE "        cout << \"obj_loc not running. Exiting.\" << endl;\n";
    print FILE "        exit (1);\n";
    print FILE "    }\n";
    print FILE "\n";
    print FILE "    char shmid_char[OBJ_LOC_SHMID_LEN];\n";
    print FILE "\n";
    print FILE "    obj_loc_file >> shmid_char;\n";
    print FILE "\n";
    print FILE "    cout << \"Attaching to obj_loc shmid: \" << shmid_char << endl;\n";
    print FILE "\n";
    print FILE "    int shmid = atoi(shmid_char);\n";
    print FILE "\n";
    print FILE "    obj_loc_file.close();\n";
    print FILE "\n";
    print FILE "    void* shm;\n";
    print FILE "\n";
    print FILE "    if ((shm = shmat(shmid, NULL, SHM_RDONLY)) == (char *) -1) {\n";
    print FILE "        perror(\"shmat\");\n";
    print FILE "        exit(1);\n";
    print FILE "    }\n";
    print FILE "\n";
    print FILE "    _obj_loc = (obj_loc*)shm;\n";
    print FILE "\n";
    print FILE "    _status_vec.push_back(\"UNKNOWN\");\n";
    print FILE "    _status_vec.push_back(\"STOPPED\");\n";
    print FILE "    _status_vec.push_back(\"STARTING\");\n";
    print FILE "    _status_vec.push_back(\"RUNNING\");\n";
    print FILE "    _status_vec.push_back(\"BLOCKED\");\n";
    print FILE "    _status_vec.push_back(\"FAILED\");\n";
    print FILE "    _status_vec.push_back(\"STALE\");\n";
    print FILE "    _status_vec.push_back(\"MANAGED\");\n";
    print FILE "\n";
    print FILE "\n";
    print FILE "    void* tmp;\n";
    print FILE "    $name* local_$name;\n";
    print FILE "\n";
    print FILE "    for ( int id = 1 ; id < MAX_OBJECTS ; id++ )\n";
    print FILE "    {\n";
    print FILE "        if ( _obj_loc->shmid[id] != 0 )\n";
    print FILE "        {\n";
    print FILE "            if (( tmp = shmat(_obj_loc->shmid[id], NULL, SHM_RDONLY)) == (char *) -1) {\n";
    print FILE "                perror(\"shmat\");\n";
    print FILE "                exit(1);\n";
    print FILE "            }\n";
    print FILE "\n";
    print FILE "            if ( ((object_header*)tmp)->type == ".type2num( $name )." )\n";
    print FILE "            {\n";
    print FILE "                row = *(_refTreeModel->append());\n";
    print FILE "\n";
    print FILE "                local_$name = (($name*)tmp);\n";
    print FILE "\n";

    print FILE "                row[_columns._col_id] = id;\n";
    print FILE "                row[_columns._col_name] = local_$name->name;\n";
    print FILE "                row[_columns._col_sleep_time] = local_$name->sleep_time;\n";
    print FILE "                row[_columns._col_last_published] = local_$name->last_published;\n";
    print FILE "                row[_columns._col_status] = _status_vec[local_$name->status];\n";
    print FILE "                row[_columns._col_pid] = local_$name->pid;;\n";

    foreach $tuple ( @static, @sub, @pub ) {

        ( $type, $var ) = split / /, $tuple;

        print FILE "                row[_columns._col_$var] = local_$name->$var;\n";

    }


    print FILE "\n";
    print FILE "                $sub_name.push_back(($name*)tmp);\n";
    print FILE "\n";
    print FILE "                my_rows.push_back( row );\n";
    print FILE "\n";
    print FILE "            }\n";
    print FILE "            else\n";
    print FILE "            {\n";
    print FILE "                shmdt( tmp );\n";
    print FILE "            }\n";
    print FILE "        }\n";
    print FILE "    }\n";
    print FILE "\n";

    print FILE "    _treeView.append_column(\"Id\", _columns._col_id);\n";
    print FILE "    _treeView.append_column(\"Name\", _columns._col_name);\n";
    print FILE "    _treeView.append_column(\"Sleep Time\", _columns._col_sleep_time);\n";
    print FILE "    _treeView.append_column(\"Last Published\", _columns._col_last_published);\n";
    print FILE "    _treeView.append_column(\"Status\", _columns._col_status);\n";
    print FILE "    _treeView.append_column(\"Pid\", _columns._col_pid);\n";

    foreach $tuple ( @static, @sub, @pub ) {

        ( $type, $var ) = split / /, $tuple;

        print FILE "    _treeView.append_column(\"".lower2label( $var )."\", _columns._col_$var);\n";

    }



    print FILE "\n";
    print FILE "    show_all_children();\n";
    print FILE "\n";
    print FILE "\n";
    print FILE "}\n";
    print FILE "\n";
    print FILE "$viewer\:\:~$viewer()\n";
    print FILE "{\n";
    print FILE "}\n";
    print FILE "\n";
    print FILE "\n";
    print FILE "bool $viewer\:\:Refresh( int timer_number)\n";
    print FILE "{\n";
    print FILE "    Gtk::TreeModel::Row row;\n";
    print FILE "    int id;\n";
    print FILE "\n";
    print FILE "    for( unsigned int i = 0 ; i < my_rows.size() ; i++ )\n";
    print FILE "    {\n";
    print FILE "        row = my_rows[i];\n";
    print FILE "        id  = row[_columns._col_id];\n";
    print FILE "\n";
    print FILE "        row[_columns._col_id] = id;\n";
    print FILE "        row[_columns._col_name] = $sub_name"."[i]->name;\n";
    print FILE "        row[_columns._col_sleep_time] = $sub_name"."[i]->sleep_time;\n";
    print FILE "        row[_columns._col_last_published] = $sub_name"."[i]->last_published;;\n";
    print FILE "        row[_columns._col_status] = _status_vec[$sub_name"."[i]->status];\n";
    print FILE "        row[_columns._col_pid] = $sub_name"."[i]->pid;;\n";

    foreach $tuple ( @static, @sub, @pub ) {

        ( $type, $var ) = split / /, $tuple;

	print FILE "        row[_columns._col_$var] = $sub_name"."[i]->$var;\n";

    }

    print FILE "\n";
    print FILE "    }\n";
    print FILE "\n";
    print FILE "    return true;\n";
    print FILE "}\n";
    print FILE "\n";
    print FILE "\n";
    print FILE "\n";
    print FILE "#include <gtkmm/main.h>\n";
    print FILE "\n";
    print FILE "int main(int argc, char *argv[])\n";
    print FILE "{\n";
    print FILE "  Gtk::Main kit(argc, argv);\n";
    print FILE "\n";
    print FILE "  $viewer window;\n";
    print FILE "  Gtk::Main::run(window); \n";
    print FILE "\n";
    print FILE "  return 0;\n";
    print FILE "}\n";






    close FILE;

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

            if ( $line =~ '\[' ) {
                push @static_vec, trim( $line );
            }
            else {
                push @static, trim( $line );
            }
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
    elsif ( $type =~ /_enum/ ) {
        return "($type)atoi";
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

    my $type_num = $types_map{$type};

    if ( ! $type_num ) {
        die "Type $type not found in $ENV{INSTANCE_ROOT}/defs/object_types.t4s";
    }
    
    return $type_num;    
}
