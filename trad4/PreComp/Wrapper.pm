# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#

package PreComp::Wrapper;

use PreComp::Utilities;
use PreComp::Constants;
use Data::Dumper;

sub generate_validator($$$);
sub generate_loader($$);
sub generate_constructor($$);
sub generate_calculate($$$$);
sub generate_need_refresh($$$$);
sub generate_loader_callback($$$$);
sub generate_extra_loaders($$$$);

sub Generate($$$$$$) {
    my $master_hash = shift;
    my $name = shift;
    my $struct_hash = shift;
    my $constants_hash = shift;
    my $new_master_hash = shift;
    my $pv3 = shift;

    my $obj_hash = $master_hash->{$name};

    my @header = PreComp::Constants::CommomHeader();

    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::GenObjRoot()."$name"."_wrapper.c" );
    if( ! $FHD ) { return; }

    print $FHD "\n";
    print $FHD "#include <iostream>\n";
    print $FHD "#include <sstream>\n";
    print $FHD "#include <cstdlib>\n";
    print $FHD "#include <cstring>\n";
    print $FHD "#include <sstream>\n";

    print $FHD "\n";
    print $FHD "\n";
    print $FHD "#include \"trad4.h\"\n";
    print $FHD "#include \"$name.h\"\n";
    print $FHD "#include \"$name"."_macros.h\"\n";

    foreach $key ( @{$obj_hash->{data}->{sub_order}} ) {

        print $FHD "#include \"".$obj_hash->{data}->{sub}->{$key}.".h\"\n";
    }

    foreach $key ( @{$obj_hash->{data}->{sub_vec_order}} ) {

        print $FHD "#include \"".$obj_hash->{data}->{sub_vec}->{$key}.".h\"\n";
    }

    print $FHD "\n";
    print $FHD "#include <sqlite3.h>\n";
    print $FHD "\n";

    if ( %{$obj_hash->{data}->{static_vec}} or %{$obj_hash->{data}->{sub_vec}} ) {

        print $FHD "static int counter(0);\n";
        print $FHD "\n";
    }

    print $FHD "void calculate_$obj_hash->{name}( obj_loc_t obj_loc, int id );\n";

    foreach $vec_name ( ( keys %{$obj_hash->{data}->{static_vec}} , keys %{$obj_hash->{data}->{sub_vec}} )) {

            $vec_short = $vec_name;
            $vec_short =~ s/\[.*\]//g;

            print $FHD "void load_$name"."_$vec_short( obj_loc_t obj_loc, int i, sqlite3* db, int initial_load );\n";
    }

    print $FHD "\n";
    print $FHD "using namespace std;\n";
    print $FHD "\n";

    generate_constructor( $obj_hash, $FHD );
    print $FHD "\n";


    generate_calculate( $master_hash, $struct_hash, $name, $FHD );
    print $FHD "\n";

    generate_need_refresh( $obj_hash, $constants_hash, $FHD, $pv3 );
    print $FHD "\n";


    generate_validator( $master_hash, $name, $FHD );
    print $FHD "\n";

    generate_loader_callback( $master_hash, $obj_hash, $struct_hash, $FHD );
    print $FHD "\n";

    generate_loader( $obj_hash, $FHD );
    print $FHD "\n";

    if ( %{$obj_hash->{data}->{static_vec}} or %{$obj_hash->{data}->{sub_vec}} ) {

        generate_extra_loaders( $obj_hash, $struct_hash, $constants_hash, $FHD );
    }

    print $FHD "\n";

    if ( $pv3 ) {
        GenerateNewLoader( $new_master_hash, $name, $FHD );
    }

    PreComp::Utilities::CloseFile();
}

sub generate_constructor($$)
{
    my $obj_hash = shift;
    my $FHD = shift;

    print $FHD "extern \"C\" void* constructor()\n";
    print $FHD "{\n";
    print $FHD "    return new $obj_hash->{name};\n";
    print $FHD "}\n";
}

sub generate_calculate($$$$)
{
    my $master_hash = shift;
    my $struct_hash = shift;
    my $name = shift;
    my $FHD = shift;

    my $obj_hash = $master_hash->{$name};

    print $FHD "extern \"C\" void calculate( obj_loc_t obj_loc, int id )\n";
    print $FHD "{\n";
    print $FHD "    DEBUG( \"calculate_$obj_hash->{name}( \" << (($name*)obj_loc[id])->name << \" )\" );\n";
    print $FHD "\n";
    print $FHD "    DEBUG_FINE( \"static:\" );\n";

    foreach $key ( @{$obj_hash->{data}->{static_order}} ) {

        print $FHD "    DEBUG_FINE( \"\\t$obj_hash->{name}_$key: \" << $obj_hash->{name}_$key );\n";

    }

    print $FHD "\n";
    print $FHD "    DEBUG_FINE( \"sub:\" );\n";

    foreach $key ( @{$obj_hash->{data}->{sub_order}} ) {

        print $FHD "    DEBUG_FINE( \"\t$key:\" );\n";

        foreach $key2 ( @{$master_hash->{$obj_hash->{data}->{sub}->{$key}}->{data}->{pub_order}} ) {

            $key_type = $master_hash->{$obj_hash->{data}->{sub}->{$key}}->{data}->{pub}->{$key2};

            if ( $struct_hash->{$key_type} ) {

                foreach $struct_type ( keys %{$struct_hash->{$key_type}->{data}} ) {

                    $struct_type_short = $struct_type;
                    $struct_type_short =~ s/\[.*\]//g;

                    if ( $struct_type eq $struct_type_short ) {

                        print $FHD "    DEBUG_FINE( \"\\t\\t$key"."_$key2.$struct_type_short: \" << $key"."_$key2.$struct_type_short );\n";

                    }
                }
            }
            else {

                print $FHD "    DEBUG_FINE( \"\\t\\t$key"."_$key2: \" << $key"."_$key2 );\n";
            }
        }

        foreach $key2 ( @{$master_hash->{$obj_hash->{data}->{sub}->{$key}}->{data}->{static_order}} ){ 

            print $FHD "    DEBUG_FINE( \"\\t\\t$key"."_$key2: \" << $key"."_$key2 );\n";
        }
    }

    print $FHD "\n";
    print $FHD "    calculate_$obj_hash->{name}( obj_loc, id );\n";
    print $FHD "\n";
    print $FHD "    DEBUG_FINE( \"pub:\");\n";

    foreach $key ( @{$obj_hash->{data}->{pub_order}} ) {

        $key_type = $obj_hash->{data}->{pub}->{$key};

        if ( $struct_hash->{$key_type} ) {

            foreach $struct_type ( keys %{$struct_hash->{$key_type}->{data}} ) {

                $struct_type_short = $struct_type;
                $struct_type_short =~ s/\[.*\]//g;

                if ( $struct_type eq $struct_type_short ) {

                    print $FHD "    DEBUG( \"\\t$obj_hash->{name}_$key.$struct_type_short: \" << $obj_hash->{name}_$key.$struct_type_short );\n";

                }
            }
        }
        else {

            print $FHD "    DEBUG( \"\\t$obj_hash->{name}_$key: \" << $obj_hash->{name}_$key );\n";
        }

    }
    print $FHD "\n";
    print $FHD "}\n";

}

sub generate_validator($$$)
{
    my $master_hash = shift;
    my $name = shift;
    my $FHD = shift;

    my $obj_hash = $master_hash->{$name};

    print $FHD "extern \"C\" int validate( obj_loc_t obj_loc, int id )\n";
    print $FHD "{\n";
    print $FHD "    int retval=0;\n";
    print $FHD "\n";

    foreach $key ( keys %{$obj_hash->{data}->{sub}} ) {

        print $FHD "    if ( ! obj_loc[(($name*)obj_loc[id])->$key] )\n";
        print $FHD "    {\n";
        print $FHD "        cout << \"Error: Type $name, id \" << id << \" failed validation because a sub object $key, id \" << (($name*)obj_loc[id])->$key << \" does not exist.\" << endl;\n";
        print $FHD "        exit(0);\n";
        print $FHD "    }\n";
        print $FHD "\n";

        print $FHD "    if ( ((object_header*)obj_loc[(($name*)obj_loc[id])->$key])->implements != $master_hash->{$master_hash->{$obj_hash->{data}->{sub}->{$key}}->{data}->{implements}}->{type_num} )\n";
        print $FHD "    {\n";

        print $FHD "        cout << \"Error: Type $name, id \" << id << \" failed validation because a sub object $key, id \" << (($name*)obj_loc[id])->$key << \" is not of type $master_hash->{$obj_hash->{data}->{sub}->{$key}}->{type_num}.\" << endl;\n";
        print $FHD "        exit(0);\n";
        print $FHD "    }\n";
        print $FHD "\n";

    }

    print $FHD "    return retval;\n";
    print $FHD "\n";
    print $FHD "}\n";
}

sub generate_need_refresh($$$$)
{
    my $obj_hash = shift;
    my $constants_hash = shift;
    my $FHD = shift;
    my $pv3 = shift;

    my $name = $obj_hash->{name};

    print $FHD "extern \"C\" int need_refresh( obj_loc_t obj_loc, int id )\n";
    print $FHD "{\n";

    print $FHD "    DEBUG_LOADS( \"$name"."_need_refresh( \" << id << \")\" );\n";

    print $FHD "\n";
    print $FHD "    DEBUG_LOADS( \"\t$name timestamp: \" <<  *(long long*)obj_loc[id] );\n";
    print $FHD "    DEBUG_LOADS( \"\t$name state: \" << ((object_header*)obj_loc[id])->status );\n";

    foreach $key ( keys %{$obj_hash->{data}->{sub}} ) {

        print $FHD "    DEBUG_LOADS( \"\t\t$key timestamp: \" << *(long long*)obj_loc[(($name*)obj_loc[id])->$key] );\n";
    }

    print $FHD "\n";
    print $FHD "    int retval = ( (((object_header*)obj_loc[id])->status == RELOADED ) || ";


    print $FHD "(((object_header*)obj_loc[id])->status == STOPPED ) && ( ";

    foreach $key ( keys %{$obj_hash->{data}->{sub}} ) {

        print $FHD "( *(long long*)obj_loc[id] < *(long long*)obj_loc[(($name*)obj_loc[id])->$key] ) || ";


    }

    foreach $vec ( keys %{$obj_hash->{data}->{sub_vec}} ) {

        $vec_type = $obj_hash->{data}->{sub_vec}->{$vec};

        my $vec_short = $vec;
        $vec_short =~ s/\[.*]$//;

        $vec_size = $vec;
        $vec_size =~ s/.*\[//g;
        $vec_size =~ s/\]//g;

        my $counter=0;

        while ( $counter < $constants_hash->{$vec_size}) { 

            if ( $pv3 ) {
                print $FHD "(object_timestamp(id) < object_timestamp( $name"."_$vec_short\($counter\) )) || ";
            }
            else {
                print $FHD "(object_timestamp(id) < object_timestamp( $name"."_$vec_short\[$counter\] )) || ";
            }

            $counter = $counter+1;
        }
    }

    print $FHD " 0 ));\n";

    print $FHD "\n";
    print $FHD "    DEBUG_LOADS( \"\treturning: \" << retval )\n";
    print $FHD "\n";
    print $FHD "    return retval;\n";
    print $FHD "\n";
    print $FHD "}\n";

}

sub generate_loader_callback($$$$)
{
    my $master_hash = shift;
    my $obj_hash = shift;
    my $struct_hash = shift;
    my $FHD = shift;

    my $name = $obj_hash->{name};


    print $FHD "\n";
    print $FHD "static int load_objects_callback(void *obj_loc_v, int argc, char **row, char **azColName)\n";
    print $FHD "{\n";
    print $FHD "    // Have to cast to unsigned char** here as C++ doesn't like\n";
    print $FHD "    //  void* arithmetic for some strange reason... \n";
    print $FHD "    unsigned char** obj_loc = (unsigned char**)obj_loc_v;\n";
    print $FHD "\n";
    print $FHD "    int id = atoi(row[0]);\n";
    print $FHD "\n";
    print $FHD "    bool is_new(false);\n";
    print $FHD "\n";
    print $FHD "    if ( !obj_loc[id] ) \n";
    print $FHD "    {\n";
    print $FHD "        obj_loc[id] = (unsigned char*)(new $name);\n";
    print $FHD "        is_new = true;\n";
    print $FHD "    }\n";
    print $FHD "\n";
    print $FHD "    (($name*)obj_loc[id])->id = id;\n";
    print $FHD "    (($name*)obj_loc[id])->log_level = atoi(row[3]);\n";
    print $FHD "    (($name*)obj_loc[id])->last_published = 0;\n";
    print $FHD "\n";
    print $FHD "    (($name*)obj_loc[id])->status = RELOADED;\n";
    print $FHD "\n";
    print $FHD "    //(($name*)obj_loc[id])->calculator_fpointer = &calculate_$name"."_wrapper;\n";
    print $FHD "    //(($name*)obj_loc[id])->need_refresh_fpointer = &$name"."_need_refresh;\n";
    print $FHD "    (($name*)obj_loc[id])->type = ".$obj_hash->{type_num}.";\n";

    print $FHD "    (($name*)obj_loc[id])->implements = ".$master_hash->{$obj_hash->{data}->{implements}}->{type_num}.";\n";
    print $FHD "    memcpy( (($name*)obj_loc[id])->name, row[1], 32 );\n";
    print $FHD "    (($name*)obj_loc[id])->tier = atoi(row[2]);\n";
    print $FHD "    \n";

    my $counter=4;

    foreach $key ( keys %{$obj_hash->{data}->{static}} ) {

        print $FHD "    (($name*)obj_loc[id])->$key = ";
        print $FHD PreComp::Utilities::Type2atoX($obj_hash->{data}->{static}->{$key})."(row[$counter]);\n";
        $counter++
    }

    foreach $key ( keys %{$obj_hash->{data}->{sub}} ) {

        print $FHD "    (($name*)obj_loc[id])->$key = atoi(row[$counter]);\n";
        $counter++
    }

    foreach $pub_var ( keys %{$obj_hash->{data}->{pub}} ) {

        $pub_var_type = $obj_hash->{data}->{pub}->{$pub_var};

        if ( $struct_hash->{$pub_var_type} ) {

            foreach $struct_type ( keys %{$struct_hash->{$pub_var_type}->{data}} ) {

                $struct_type_short = $struct_type;
                $struct_type_short =~ s/\[.*\]//g;

                if ( $struct_type eq $struct_type_short ) {

                    print $FHD "    (($name*)obj_loc[id])->$pub_var.$struct_type_short = 0;\n";

                }
            }
        } 
        else {

            print $FHD "    (($name*)obj_loc[id])->$pub_var = 0;\n";
        }
    }

    print $FHD "\n";

    print $FHD "    if ( is_new )\n";
    print $FHD "    {\n";
    print $FHD "        //std::cout << \"New $name created.\" << std::endl;\n";
    print $FHD "    }\n";

    print $FHD "\n";
    print $FHD "    return 0;\n";
    print $FHD "} \n";

}

sub generate_loader($$)
{
    my $obj_hash = shift;
    my $FHD = shift;

    my $name = $obj_hash->{name};

    print $FHD "\n";
    print $FHD "extern \"C\" void load_objects( obj_loc_t obj_loc, int initial_load )\n";
    print $FHD "{\n";
    print $FHD "    std::cout << \"load_all_$name"."s()\" << std::endl;\n";
    print $FHD "\n";
    print $FHD "    char *zErrMsg = 0;\n";
    print $FHD "    sqlite3* db;\n";
    print $FHD "    sqlite3_open(getenv(\"APP_DB\"), &db);\n";
    print $FHD "\n";
    print $FHD "    std::ostringstream dbstream;\n";
    print $FHD "    dbstream << \"select o.id, o.name, o.tier, o.log_level ";

    foreach $key ( keys %{$obj_hash->{data}->{static}} ) {
        print $FHD ", t.$key ";
    }

    foreach $key ( keys %{$obj_hash->{data}->{sub}} ) {
        print $FHD ", t.$key ";
    }

    print $FHD " from object o, object_types ot";

    if ( %{$obj_hash->{data}->{static}} or %{$obj_hash->{data}->{sub}} ) {
        print $FHD ", $name t ";
    }

    print $FHD " where ";

    if ( %{$obj_hash->{data}->{static}} or %{$obj_hash->{data}->{sub}} ) {
        print $FHD " o.id = t.id and ";

    }
    print $FHD " o.type = ot.type_id and o.type = ".$obj_hash->{type_num}."\";\n";

    
    print $FHD "\n";
    print $FHD "    if ( initial_load != 1 )\n";
    print $FHD "        dbstream << \" and o.need_reload=1\";\n";
    print $FHD "\n";

    print $FHD "    if( sqlite3_exec(db, dbstream.str().c_str(), load_objects_callback, obj_loc, &zErrMsg) != SQLITE_OK ){\n";
    print $FHD "        fprintf(stderr, \"SQL error: %s. File %s, line %d.\\n\", zErrMsg, __FILE__, __LINE__);\n";
    print $FHD "        sqlite3_free(zErrMsg);\n";
    print $FHD "    }\n";
    print $FHD "\n";

    if ( %{$obj_hash->{data}->{static_vec}} or %{$obj_hash->{data}->{sub_vec}} ) {

        print $FHD "\n";
        print $FHD "    for ( int i = 0 ; i < MAX_OBJECTS+1 ; i++ )\n";
        print $FHD "    {\n";
        print $FHD "        if ( obj_loc[i] && ((object_header*)obj_loc[i])->type == $obj_hash->{type_num} && ((object_header*)obj_loc[i])->status == RELOADED)\n";
        print $FHD "        {\n";

        my $vec_short;

        foreach $vec_name ( ( keys %{$obj_hash->{data}->{static_vec}}, keys %{$obj_hash->{data}->{sub_vec}} )) {

                $vec_short = $vec_name;
                $vec_short =~ s/\[.*\]//g;

                print $FHD "            load_$name"."_$vec_short( obj_loc, i, db, 0 );\n";
                print $FHD "            if ( counter == 0 ) { std::cout << \"Warning: Table $name"."_$vec_short is empty for id \" << i << \".\" << std::endl; }\n";
        }

        print $FHD "        }\n";
        print $FHD "    }\n";
        print $FHD "\n";
        print $FHD "\n";
    }

    print $FHD "}\n";

    print $FHD "\n";

}

sub generate_extra_loaders($$$$)
{
    my $obj_hash = shift;
    my $struct_hash = shift;
    my $constants_hash = shift;
    my $FHD = shift;

    my $name = $obj_hash->{name};

    my ( $vec_type, $vec_short ); 

    foreach $vec_name ( keys %{$obj_hash->{data}->{static_vec}} ) {
       
        $vec_type = $obj_hash->{data}->{static_vec}->{$vec_name};

        $vec_short = $vec_name;
        $vec_short =~ s/\[.*\]//g;

        $vec_size = $vec_name;
        $vec_size =~ s/.*\[//g;
        $vec_size =~ s/\]//g;

        print $FHD "static int load_$name"."_$vec_short"."_callback(void *obj_loc_v, int argc, char **row, char **azColName)\n";
        print $FHD "{\n";
        print $FHD "    unsigned char** obj_loc = (unsigned char**)obj_loc_v;\n";
        print $FHD "    int id = atoi(row[0]);\n";
        print $FHD "\n";
        print $FHD "    if ( counter > $vec_size )\n";
        print $FHD "    {\n";
        print $FHD "        cerr << \"Error in load_$name"."_$vec_short: The number of rows in $name"."_$vec_short.table is greater than $vec_size. Truncating data in $name"."_$vec_short structure to ".$constants_hash->{$vec_size}." elements. Suggest you fix the data or create a new type with larger arrays and migrate your objects across.\" << endl;\n";
        print $FHD "    }\n";
        print $FHD "    else\n";
        print $FHD "    {\n";

        if ( $struct_hash->{$vec_type} ) {

            my $row_num=1;

            foreach $key ( @{$struct_hash->{$vec_type}{order}} ) {

                print $FHD "        $name"."_$vec_short"."_$key(counter) = ".PreComp::Utilities::Type2atoX( $struct_hash->{$vec_type}{data}{$key} )."(row[$row_num]);\n";

                $row_num = $row_num + 1;
            }
        }
        else {
            print $FHD "        ($name"."_$vec_short"."[counter]) = ".PreComp::Utilities::Type2atoX( $vec_type )."(row[1]);\n";
        }

        print $FHD "\n";
        print $FHD "        counter++;\n";
        print $FHD "\n";
        print $FHD "    }\n";
        print $FHD "\n";
        print $FHD "    return 0;\n";
        print $FHD "}\n";
        print $FHD "\n";
        print $FHD "void load_$name"."_$vec_short( obj_loc_t obj_loc, int id, sqlite3* db, int initial_load )\n";
        print $FHD "{\n";
        print $FHD "    cout << \"\tload_$name"."_$vec_short()\" << endl;\n";
        print $FHD "\n";
        print $FHD "    counter = 0;\n";
        print $FHD "    char *zErrMsg = 0;\n";
        print $FHD "\n";
        print $FHD "    std::ostringstream dbstream;\n";
        print $FHD "    dbstream << \"select id";
    
        if ( $struct_hash->{$vec_type} ) {

            foreach $key ( @{$struct_hash->{$vec_type}{order}} ) {

                print $FHD ", $key";
            }
        }
        else {

            print $FHD ", $vec_short";
        }

        print $FHD " from $name"."_$vec_short where id = \" << id;\n";

        print $FHD "\n";
        print $FHD "    if( sqlite3_exec(db, dbstream.str().c_str(), load_$name"."_$vec_short"."_callback, obj_loc, &zErrMsg) != SQLITE_OK ){\n";
        print $FHD "        fprintf(stderr, \"SQL error: %s. File %s, line %d.\\n\", zErrMsg, __FILE__, __LINE__);\n";
        print $FHD "        sqlite3_free(zErrMsg);\n";
        print $FHD "    }\n";
        print $FHD "\n";
        print $FHD "}\n";
        
    }

    foreach $vec_name ( keys %{$obj_hash->{data}->{sub_vec}} ) {
       
        $vec_type = $obj_hash->{data}->{sub_vec}->{$vec_name};

        $vec_short = $vec_name;
        $vec_short =~ s/\[.*\]//g;

        $vec_size = $vec_name;
        $vec_size =~ s/.*\[//g;
        $vec_size =~ s/\]//g;

        print $FHD "static int load_$name"."_$vec_short"."_callback(void *obj_loc_v, int argc, char **row, char **azColName)\n";
        print $FHD "{\n";
        print $FHD "    unsigned char** obj_loc = (unsigned char**)obj_loc_v;\n";
        print $FHD "    int id = atoi(row[0]);\n";
        print $FHD "\n";
        print $FHD "    if ( counter > $vec_size )\n";
        print $FHD "    {\n";
        print $FHD "        cerr << \"Error in load_$name"."_$vec_short: The number of rows in $name"."_$vec_short.table is greater than $vec_size. Truncating data in $name"."_$vec_short structure to ".$constants_hash->{$vec_size}." elements. Suggest you fix the data or create a new type with larger arrays and migrate your objects across.\" << endl;\n";
        print $FHD "    }\n";
        print $FHD "    else\n";
        print $FHD "    {\n";

        print $FHD "        ($name"."_$vec_short"."[counter]) = atoi(row[1]);\n";

        print $FHD "\n";
        print $FHD "        counter++;\n";
        print $FHD "\n";
        print $FHD "    }\n";
        print $FHD "\n";
        print $FHD "    return 0;\n";
        print $FHD "}\n";
        print $FHD "\n";
        print $FHD "void load_$name"."_$vec_short( obj_loc_t obj_loc, int id, sqlite3* db, int initial_load )\n";
        print $FHD "{\n";
        print $FHD "    cout << \"\tload_$name"."_$vec_short()\" << endl;\n";
        print $FHD "\n";
        print $FHD "    counter = 0;\n";
        print $FHD "    char *zErrMsg = 0;\n";
        print $FHD "\n";
        print $FHD "    std::ostringstream dbstream;\n";
        print $FHD "    dbstream << \"select id";
    
        if ( $struct_hash->{$vec_type} ) {

            foreach $key ( @{$struct_hash->{$vec_type}{order}} ) {

                print $FHD ", $key";
            }
        }
        else {

            print $FHD ", $vec_short";
        }

        print $FHD " from $name"."_$vec_short where id = \" << id;\n";

        print $FHD "\n";
        print $FHD "    if( sqlite3_exec(db, dbstream.str().c_str(), load_$name"."_$vec_short"."_callback, obj_loc, &zErrMsg) != SQLITE_OK ){\n";
        print $FHD "        fprintf(stderr, \"SQL error: %s. File %s, line %d.\\n\", zErrMsg, __FILE__, __LINE__);\n";
        print $FHD "        sqlite3_free(zErrMsg);\n";
        print $FHD "    }\n";
        print $FHD "\n";
        print $FHD "}\n";
        
    }

}

sub GenerateNewLoader($$$) {
    my $master_hash = shift;
    my $type = shift;
    my $FHD = shift;

    print $FHD "extern \"C\" void new_load_objects( obj_loc_t obj_loc, int initial_load )\n";
    print $FHD "{\n";
    print $FHD "    std::cout << \"load_all_$type"."()\" << std::endl;\n";
    print $FHD "\n";
    print $FHD "    char *zErrMsg = 0;\n";
    print $FHD "    sqlite3* db;\n";
    print $FHD "    sqlite3_open(getenv(\"APP_DB\"), &db);\n";
    print $FHD "\n";
    print $FHD "    std::ostringstream dbstream;\n";
    print $FHD "    dbstream << \"select object.id, object.name, object.tier, object.log_level";

    my $section;

    foreach $section ( "static", "sub" ) {

        my ( $var_name, $var_type );

        foreach $var_name ( @{$master_hash->{$type}->{$section}->{order}} ) {

            $var_name_stripped = PreComp::Utilities::StripBrackets( $var_name );
            $var_type = $master_hash->{$type}->{$section}->{data}->{$var_name};

            print $FHD ", $type.$var_name_stripped";
        }

    }

    print $FHD " from object, object_types, $type where object.id = $type.id and object_types.type_id = object.type_id and object.type_id = $master_hash->{$type}->{type_id}\";\n";

    print $FHD "\n";
    print $FHD "    if ( initial_load != 1 )\n";
    print $FHD "        dbstream << \" and o.need_reload=1\";\n";
    print $FHD "\n";
    print $FHD "    if( sqlite3_exec(db, dbstream.str().c_str(), load_objects_callback, obj_loc, &zErrMsg) != SQLITE_OK ){\n";
    print $FHD "        fprintf(stderr, \"SQL error: %s. File %s, line %d.\\n\", zErrMsg, __FILE__, __LINE__);\n";
    print $FHD "        sqlite3_free(zErrMsg);\n";
    print $FHD "    }\n";
    print $FHD "\n";
    print $FHD "}\n";

}


1;

