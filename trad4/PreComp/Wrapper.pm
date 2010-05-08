# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#

package PreComp::Wrapper;

use PreComp::Utilities;
use PreComp::Constants;
use Data::Dumper;

sub generate_calculate($$$$);

sub GenerateExtraSection($$$$$$$);

sub Generate($$$$$) {
    my $master_hash = shift;
    my $name = shift;
    my $struct_hash = shift;
    my $constants_hash = shift;
    my $new_master_hash = shift;

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
    print $FHD "#include <cstdio>\n";

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

    print $FHD "int calculate_$obj_hash->{name}( obj_loc_t obj_loc, int id );\n";

    print $FHD "\n";
    print $FHD "using namespace std;\n";
    print $FHD "\n";

#    generate_calculate( $master_hash, $struct_hash, $name, $FHD );
    GenerateCalculate( $new_master_hash, $name, $FHD );
    print $FHD "\n";

    GenerateNeedRefresh( $new_master_hash, $name, $FHD );
    print $FHD "\n";

    GenerateValidator( $new_master_hash, $name, $FHD );

    print $FHD "\n";

    print $FHD "\n";

    GenerateExtraLoaders( $new_master_hash, $name, $FHD );
    GenerateLoaderCallback( $new_master_hash, $name, $FHD );
    GenerateNewLoader( $new_master_hash, $name, $FHD );
    GenerateConcreteGraph( $new_master_hash, $name, $FHD );

    print $FHD "\n";

    PreComp::Utilities::CloseFile();
}

#######################################################
# pv3 stuff..

use strict;
use warnings;

sub GenerateExtraLoaders($$$) {
    my $master_hash = shift;
    my $type = shift;
    my $FHD = shift;

    my $type_id = $master_hash->{$type}->{type_id};

    my $section;

    foreach $section ( "static", "sub" ) {

        my ( $var_name, $var_name_stripped, $var_type );

        foreach $var_name ( @{$master_hash->{$type}->{$section}->{order}} ) {

            $var_name_stripped = PreComp::Utilities::StripBrackets( $var_name );
            $var_type = $master_hash->{$type}->{$section}->{data}->{$var_name};

            if ( exists $master_hash->{structures}->{data}->{$var_type} or PreComp::Utilities::IsArray( $var_name ) ) {

                GenerateExtraSection( $master_hash, $type_id, $var_name, $var_type, $type, 0, $FHD );

            }
        }
    }
}

sub GenerateExtraSection($$$$$$$) {
    my $master_hash = shift;
    my $type_id = shift;
    my $var_name = shift;
    my $var_type = shift;
    my $table_name = shift;
    my $depth = shift;
    my $FHD = shift;

    my $var_name_stripped = PreComp::Utilities::StripBrackets( $var_name );

    $table_name = $table_name."_".$var_name_stripped;

    if ( $var_name ne $var_name_stripped ) {
        $depth = $depth + 1;
    }

    if ( exists $master_hash->{structures}->{data}->{$var_type} ) {

        my ( $struct_var_name, $struct_var_type, $struct_var_name_stripped );

        my $has_primitives=0;

        foreach $struct_var_name ( @{$master_hash->{structures}->{data}->{$var_type}->{order}} ) {

            $struct_var_type = $master_hash->{structures}->{data}->{$var_type}->{data}->{$struct_var_name};

            if ( exists $master_hash->{structures}->{data}->{$struct_var_type} or PreComp::Utilities::IsArray( $struct_var_name ) ) {
                GenerateExtraSection( $master_hash, $type_id, $struct_var_name, $struct_var_type, $table_name, $depth, $FHD );
            }
            else {
                $has_primitives = ( $has_primitives or 1);

            }
        }

        if ( $has_primitives ) {
            PrintExtraLoaderCallback( $master_hash, $type_id, $table_name, $var_name, $var_type, $depth, $FHD );
        }

        PrintExtraLoader( $master_hash, $type_id, $table_name, $var_name, $var_type, $depth, $has_primitives, $FHD );

    }
    elsif ( PreComp::Utilities::IsArray( $var_name ) ) {

        PrintArrayLoaderCallback( $master_hash, $type_id, $table_name, $var_name, $var_type, $depth, $FHD );
        PrintArrayLoader( $master_hash, $type_id, $table_name, $var_name, $var_type, $depth, 1, $FHD );
    }
    else {

print "Error?\n";
    }
}

sub PrintArrayLoaderCallback($$) {
    my $master_hash = shift;
    my $type_id = shift;
    my $table_name = shift;
    my $var_name = shift;
    my $var_type = shift;
    my $depth = shift;
    my $FHD = shift;

    my $var_name_stripped = PreComp::Utilities::StripBrackets( $var_name );
    my $function_name = "load_$table_name"."_callback";

    my $vec_size = PreComp::Utilities::GetArraySize( $master_hash, $var_name );

    print $FHD "static int $function_name(void *obj_loc_v, int argc, char **row, char **azColName)\n";
    print $FHD "{\n";
    print $FHD "    unsigned char** obj_loc = (unsigned char**)obj_loc_v;\n";
    print $FHD "    int id = atoi(row[0]);\n";

    my $counter = 1;

    my $arg_string="(";
    my $last_ord = "";

    my $i;
    for ( $i = 1 ; $i < $depth ; $i++ ) {

        print $FHD "    int ord$i = atoi(row[$counter]);\n";

        $last_ord = "ord$i";

        if ( $counter > 1 ) {
            $arg_string = $arg_string.", ";
        }

        $arg_string = $arg_string." ord$i";

        $counter = $counter+1;
    }

    print $FHD "\n";

    my $col;

    for ( $col = 0 ; $col < $vec_size ; $col++ ) {

        if ( $depth == 1 and $arg_string =~ /^\(/ ) {
            print $FHD "   $table_name\[$col\] = ".PreComp::Utilities::NewType2atoX( $master_hash, $var_type )."(row[$counter]);\n";

        }
        else {

            print $FHD "    $table_name$arg_string, $col ) = ".PreComp::Utilities::NewType2atoX( $master_hash, $var_type )."(row[$counter]);\n";

        }

        $counter = $counter+1;
    }

    print $FHD "\n";
    print $FHD "    return 0;\n";
    print $FHD "}\n";
    print $FHD "\n";
}

sub PrintExtraLoaderCallback($$) {
    my $master_hash = shift;
    my $type_id = shift;
    my $table_name = shift;
    my $var_name = shift;
    my $var_type = shift;
    my $depth = shift;
    my $FHD = shift;

    my $var_name_stripped = PreComp::Utilities::StripBrackets( $var_name );
    my $function_name = "load_$table_name"."_callback";

    my $vec_size = $var_name;
    $vec_size =~ s/.*\[//g;
    $vec_size =~ s/\]//g;


    print $FHD "static int $function_name(void *obj_loc_v, int argc, char **row, char **azColName)\n";
    print $FHD "{\n";
    print $FHD "    unsigned char** obj_loc = (unsigned char**)obj_loc_v;\n";
    print $FHD "    int id = atoi(row[0]);\n";

    my $counter = 1;

    my $arg_string="(";
    my $last_ord = "";

    my $i;
    for ( $i = 1 ; $i <= $depth ; $i++ ) {

        print $FHD "    int ord$i = atoi(row[$counter]);\n";

        $last_ord = "ord$i";

        if ( $counter > 1 ) {
            $arg_string = $arg_string.", ";
        }

        $arg_string = $arg_string." ord$i";

        $counter = $counter+1;
    }

    $arg_string = $arg_string." )";

    my $if_string;

    if ( $counter == 1 ) {

        $arg_string="";
        $if_string = "0";
    }
    else {
    
        $if_string = "$last_ord > $vec_size";
    }

    print $FHD "\n";
    print $FHD "    if ( $if_string )\n";
    print $FHD "    {\n";

    print $FHD "        cerr << \"Error in load_$table_name"."_callback: The number of rows in $table_name.table is greater than $vec_size. Truncating data in $var_type"."_$var_name_stripped structure to $vec_size elements. Suggest you fix the data or create a new type with larger arrays and migrate your objects across.\" << endl;\n";
    print $FHD "    }\n";
    print $FHD "    else\n";
    print $FHD "    {\n";

    if ( exists $master_hash->{structures}->{data}->{$var_type} ) {

        my ( $struct_var_name, $struct_var_type, $struct_var_name_stripped );

        foreach $struct_var_name ( @{$master_hash->{structures}->{data}->{$var_type}->{order}} ) {

            $struct_var_type = $master_hash->{structures}->{data}->{$var_type}->{data}->{$struct_var_name};
            $struct_var_name_stripped = PreComp::Utilities::StripBrackets( $struct_var_name );

            if ( not exists $master_hash->{structures}->{data}->{$struct_var_type} and not PreComp::Utilities::IsArray( $struct_var_name )) {

                print $FHD "        $table_name"."_$struct_var_name_stripped$arg_string  = ".PreComp::Utilities::NewType2atoX( $master_hash, $struct_var_type )."(row[$counter]);\n";
                $counter = $counter+1;
            }
        }
    }
    else {

        if ( $depth == 1 and $arg_string =~ /( ord1 )/ ) {

            $arg_string = "[ord1]";
        }

        print $FHD "        $table_name$arg_string = ".PreComp::Utilities::NewType2atoX( $master_hash, $var_type )."(row[$counter]);\n";

    }

    print $FHD "    }\n";
    print $FHD "\n";
    print $FHD "    return 0;\n";
    print $FHD "}\n";
    print $FHD "\n";
}

sub PrintArrayLoader($$) {
    my $master_hash = shift;
    my $type_id = shift;
    my $table_name = shift;
    my $var_name = shift;
    my $var_type = shift;
    my $depth = shift;
    my $has_primitives = shift;
    my $FHD = shift; 

    my $var_name_stripped = PreComp::Utilities::StripBrackets( $var_name );
    my $function_name = "load_$table_name";

    print $FHD "void $function_name( obj_loc_t obj_loc, sqlite3* db, int initial_load )\n";
    print $FHD "{\n";
    print $FHD "    cout << \"\t$function_name()\" << endl;\n";
    print $FHD "\n";

    if ( $has_primitives ) {

        print $FHD "    char *zErrMsg = 0;\n";
        print $FHD "\n";
        print $FHD "    std::ostringstream dbstream;\n";
        print $FHD "    dbstream << \"select object.id";

        my $i;
        for ( $i = 1 ; $i < $depth ; $i++ ) {

            print $FHD ", $table_name.ord$i";
        }

        my $vec_size = PreComp::Utilities::GetArraySize( $master_hash, $var_name );

        my $col;

        for ( $col = 0 ; $col < $vec_size ; $col++ ) {

            print $FHD ", $table_name.col$col";
        }

        print $FHD " from object, $table_name where object.id = $table_name.id and object.type_id = $type_id\";\n";

        print $FHD "    if ( initial_load != 1 )\n";
        print $FHD "        dbstream << \" and object.need_reload=1\";\n";
        print $FHD "\n";

        print $FHD "\n";
        print $FHD "    if( sqlite3_exec(db, dbstream.str().c_str(), $function_name"."_callback, obj_loc, &zErrMsg) != SQLITE_OK ){\n";
        print $FHD "        fprintf(stderr, \"SQL error: %s. File %s, line %d.\\n\", zErrMsg, __FILE__, __LINE__);\n";
        print $FHD "        sqlite3_free(zErrMsg);\n";
        print $FHD "        exit(0);\n";
        print $FHD "    }\n";
        print $FHD "\n";

    }

    print $FHD "}\n";
}

sub PrintExtraLoader($$) {
    my $master_hash = shift;
    my $type_id = shift;
    my $table_name = shift;
    my $var_name = shift;
    my $var_type = shift;
    my $depth = shift;
    my $has_primitives = shift;
    my $FHD = shift; 

    my $var_name_stripped = PreComp::Utilities::StripBrackets( $var_name );
    my $function_name = "load_$table_name";

    print $FHD "void $function_name( obj_loc_t obj_loc, sqlite3* db, int initial_load )\n";
    print $FHD "{\n";
    print $FHD "    cout << \"\t$function_name()\" << endl;\n";
    print $FHD "\n";

    if ( $has_primitives ) {

        print $FHD "    char *zErrMsg = 0;\n";
        print $FHD "\n";
        print $FHD "    std::ostringstream dbstream;\n";
        print $FHD "    dbstream << \"select object.id";

        my $i;
        for ( $i = 1 ; $i <= $depth ; $i++ ) {

            print $FHD ", $table_name.ord$i";
        }


        if ( exists $master_hash->{structures}->{data}->{$var_type} ) {

            my ( $struct_var_name, $struct_var_type, $struct_var_name_stripped );

            foreach $struct_var_name ( @{$master_hash->{structures}->{data}->{$var_type}->{order}} ) {

                $struct_var_type = $master_hash->{structures}->{data}->{$var_type}->{data}->{$struct_var_name};
                $struct_var_name_stripped = PreComp::Utilities::StripBrackets( $struct_var_name );

                if ( not PreComp::Utilities::IsArray( $struct_var_name )) {
                    print $FHD ", $table_name.$struct_var_name_stripped";
                }
            }

        }
        else {

            print $FHD ", $table_name.$var_name_stripped ";

        }

        print $FHD " from object, $table_name where object.id = $table_name.id and object.type_id = $type_id\";\n";

        print $FHD "    if ( initial_load != 1 )\n";
        print $FHD "        dbstream << \" and object.need_reload=1\";\n";
        print $FHD "\n";

        print $FHD "\n";
        print $FHD "    if( sqlite3_exec(db, dbstream.str().c_str(), $function_name"."_callback, obj_loc, &zErrMsg) != SQLITE_OK ){\n";
        print $FHD "        fprintf(stderr, \"SQL error: %s. File %s, line %d.\\n\", zErrMsg, __FILE__, __LINE__);\n";
        print $FHD "        sqlite3_free(zErrMsg);\n";
        print $FHD "        exit(0);\n";
        print $FHD "    }\n";
        print $FHD "\n";

    }

    if ( exists $master_hash->{structures}->{data}->{$var_type} ) {

        my ( $struct_var_name, $struct_var_type, $struct_var_name_stripped );

        foreach $struct_var_name ( @{$master_hash->{structures}->{data}->{$var_type}->{order}} ) {

            $struct_var_type = $master_hash->{structures}->{data}->{$var_type}->{data}->{$struct_var_name};
            $struct_var_name_stripped = PreComp::Utilities::StripBrackets( $struct_var_name );

            if ( PreComp::Utilities::IsArray( $struct_var_name )) {
                print $FHD "    load_$table_name"."_$struct_var_name_stripped( obj_loc, db, initial_load);\n";
            }
        }

    }

    print $FHD "}\n";
}

sub GenerateNewLoader($$$) {
    my $master_hash = shift;
    my $type = shift;
    my $FHD = shift;

    print $FHD "extern \"C\" void load_objects( obj_loc_t obj_loc, int initial_load )\n";
    print $FHD "{\n";
    print $FHD "    std::cout << \"Loading $type..\" << std::endl;\n";
    print $FHD "\n";
    print $FHD "    char *zErrMsg = 0;\n";
    print $FHD "    sqlite3* db;\n";
    print $FHD "    sqlite3_open(getenv(\"APP_DB\"), &db);\n";
    print $FHD "\n";
    print $FHD "    std::ostringstream dbstream;\n";
    print $FHD "    dbstream << \"select object.id, object.name, object.tier, object.log_level";

    my $section;

    foreach $section ( "static", "sub" ) {

        my ( $var_name, $var_name_stripped, $var_type );

        foreach $var_name ( @{$master_hash->{$type}->{$section}->{order}} ) {

            $var_name_stripped = PreComp::Utilities::StripBrackets( $var_name );
            $var_type = $master_hash->{$type}->{$section}->{data}->{$var_name};

            if ( not ( exists $master_hash->{structures}->{data}->{$var_type} or PreComp::Utilities::IsArray( $var_name ))) {
                print $FHD ", $type.$var_name_stripped";
            }
        }

    }

    print $FHD " from object, object_types, $type where object.id = $type.id and object_types.type_id = object.type_id and object.type_id = $master_hash->{$type}->{type_id}\";\n";

    print $FHD "\n";
    print $FHD "    if ( initial_load != 1 )\n";
    print $FHD "        dbstream << \" and object.need_reload=1\";\n";
    print $FHD "\n";
    print $FHD "    if( sqlite3_exec(db, dbstream.str().c_str(), load_objects_callback, obj_loc, &zErrMsg) != SQLITE_OK ){\n";
    print $FHD "        fprintf(stderr, \"SQL error: %s. File %s, line %d.\\n\", zErrMsg, __FILE__, __LINE__);\n";
    print $FHD "        sqlite3_free(zErrMsg);\n";
    print $FHD "        exit(0);\n";
    print $FHD "    }\n";
    print $FHD "\n";

    foreach $section ( "static", "sub" ) {

        my ( $var_name, $var_name_stripped, $var_type );

        foreach $var_name ( @{$master_hash->{$type}->{$section}->{order}} ) {

            $var_type = $master_hash->{$type}->{$section}->{data}->{$var_name};

            if ( exists $master_hash->{structures}->{data}->{$var_type} or PreComp::Utilities::IsArray( $var_name ) ) {
                $var_name_stripped = PreComp::Utilities::StripBrackets( $var_name );
                my $function_name = "load_$type"."_$var_name_stripped";

                print $FHD "    $function_name( obj_loc, db, initial_load );\n";
            }
        }
    }

    print $FHD "}\n";

}

sub GenerateLoaderCallback($$$$) {
    my $master_hash = shift;
    my $type = shift;
    my $FHD = shift;


    print $FHD "\n";
    print $FHD "static int load_objects_callback(void *obj_loc_v, int argc, char **row, char **azColName)\n";
    print $FHD "{\n";
    print $FHD "    void** obj_loc = (void**)obj_loc_v;\n";
    print $FHD "\n";
    print $FHD "    int id = atoi(row[0]);\n";
    print $FHD "\n";
    print $FHD "\n";
    print $FHD "    if ( !obj_loc[id] ) \n";
    print $FHD "    {\n";
    print $FHD "        obj_loc[id] = (unsigned char*)(new t4::$type);\n";
    print $FHD "        object_init(id) = 0;\n";
    print $FHD "    }\n";
    print $FHD "\n";
    print $FHD "    object_status(id) = OK;\n";
    print $FHD "\n";
    print $FHD "    ((t4::$type*)obj_loc[id])->id = id;\n";
    print $FHD "    memcpy( ((t4::$type*)obj_loc[id])->name, row[1], 32 );\n";
    print $FHD "    object_tier(id) = atoi(row[2]);\n";
    print $FHD "    object_log_level(id) =  atoi(row[3]);\n";
    print $FHD "\n";
    print $FHD "    object_last_published(id) = 0;\n";
    print $FHD "    object_type(id) = $master_hash->{$type}->{type_id};\n";
    print $FHD "    object_implements(id) = $master_hash->{$master_hash->{$type}->{implements}}->{type_id};\n";
            
    print $FHD "\n";

    print $FHD "    \n";

    my $counter=4;

    my $section;

    foreach $section ( "static", "sub" ) {

        my ( $var_name, $var_name_stripped, $var_type );

        foreach $var_name ( @{$master_hash->{$type}->{$section}->{order}} ) {

            $var_name_stripped = PreComp::Utilities::StripBrackets( $var_name );
            $var_type = $master_hash->{$type}->{$section}->{data}->{$var_name};

            if ( exists $master_hash->{structures}->{data}->{$var_type} ) {

                # Do nothing
            }
            elsif ( PreComp::Utilities::IsArray( $var_name ) ) {

                print $FHD "    for ( int i = 0 ; i < ".PreComp::Utilities::GetArraySize( $master_hash, $var_name )." ; i++ )\n";
                print $FHD "    {\n";
                print $FHD "        $type"."_$var_name_stripped"."[i] = 0;\n";
                print $FHD "    }\n";

            }
            elsif ( exists $master_hash->{$var_type} ) {


                print $FHD "    $type"."_$var_name_stripped = atoi(row[$counter]);\n";
                $counter = $counter+1;
            }
            else {

                print $FHD "    $type"."_$var_name_stripped = ".PreComp::Utilities::NewType2atoX( $master_hash, $var_type )."(row[$counter]);\n";
                $counter = $counter+1;
                
            }
            
        }

    }
    

    print $FHD "\n";

    print $FHD "    return 0;\n";
    print $FHD "} \n";

}


sub GenerateNeedRefresh($$$) {
    my $master_hash = shift;
    my $type = shift;
    my $FHD = shift;

    print $FHD "extern \"C\" int need_refresh( obj_loc_t obj_loc, int id )\n";
    print $FHD "{\n";

    print $FHD "    DEBUG_LOADS( \"$type"."_need_refresh( \" << id << \")\" );\n";

    print $FHD "\n";

    my $var_name;
if (0) {

    print $FHD "    if ( \n";


    foreach $var_name ( @{$master_hash->{$type}->{sub}->{order}} ) {

        if ( PreComp::Utilities::IsArray( $var_name ) ) {

            my $var_name_stripped = PreComp::Utilities::StripBrackets( $var_name );

            my $size = PreComp::Utilities::GetArraySize( $master_hash, $var_name );

            my $counter=0;

            while ( $counter < $size ) {

                print $FHD "        ((((t4::$type*)obj_loc[id])->$var_name_stripped"."[$counter]) and not ((t4::$type*)obj_loc[id])->$var_name_stripped"."[$counter]) ||\n";
                $counter = $counter+1;
            }
        }
        else {
            print $FHD "         not ((t4::$type*)obj_loc[id])->$var_name ||\n";
        }

    }

    print $FHD "        0 )\n";
    print $FHD "    {\n";
    print $FHD "        DEBUG_LOADS( \"Error: Object \" << id << \" has invalid sub objects. Cannot check sub timestamp.\" );\n";

    print $FHD "        return 0;\n";
    print $FHD "    }\n";


}

    print $FHD "\n";

    print $FHD "    DEBUG_LOADS( \"\t$type last_published: \" <<  object_last_published(id) );\n";

    foreach $var_name ( @{$master_hash->{$type}->{sub}->{order}} ) {

        if ( PreComp::Utilities::IsArray( $var_name ) ) {

            my $var_name_stripped = PreComp::Utilities::StripBrackets( $var_name );

            my $size = PreComp::Utilities::GetArraySize( $master_hash, $var_name );

            my $counter=0;

            while ( $counter < $size ) {

                print $FHD "    DEBUG_LOADS( \"\t\t$var_name_stripped"."[$counter] last_published: \" << object_last_published(((t4::$type*)obj_loc[id])->$var_name_stripped"."[$counter]) );\n";

                $counter = $counter+1;
            }
        }
        else {

            print $FHD "    DEBUG_LOADS( \"\t\t$var_name last_published: \" << object_last_published(((t4::$type*)obj_loc[id])->$var_name) );\n";
        }
    }

    print $FHD "\n";

    print $FHD "    int retval = ( (object_last_published(id) == 0 )\n";

    foreach $var_name ( @{$master_hash->{$type}->{sub}->{order}} ) {

        if ( PreComp::Utilities::IsArray( $var_name ) ) {

            my $var_name_stripped = PreComp::Utilities::StripBrackets( $var_name );

            my $size = PreComp::Utilities::GetArraySize( $master_hash, $var_name );
            
            my $counter=0;

            while ( $counter < $size ) {

                print $FHD "        || ((((t4::$type*)obj_loc[id])->$var_name_stripped"."[$counter]) and ( object_last_published(id) < object_last_published(((t4::$type*)obj_loc[id])->$var_name_stripped"."[$counter]) ))\n";
                $counter = $counter+1;
            }
        }
        else {
            print $FHD "        || ( object_last_published(id) < object_last_published(((t4::$type*)obj_loc[id])->$var_name) )\n";
        }

    }

    print $FHD "        );\n";

    print $FHD "\n";
    print $FHD "    DEBUG_LOADS( \"\treturning: \" << retval )\n";
    print $FHD "\n";
    print $FHD "    return retval;\n";

    print $FHD "}\n";

}

sub GenerateCalculate($$$) {
    my $master_hash = shift;
    my $type = shift;
    my $FHD = shift;
    
    print $FHD "extern \"C\" void calculate( obj_loc_t obj_loc, int id )\n";
    print $FHD "{\n";
    print $FHD "\n";
    print $FHD "    DEBUG( \"calculate_$type( \" << ((t4::$type*)obj_loc[id])->name << \" )\" );\n";
    print $FHD "\n";

    print $FHD "    DEBUG_FINE( \"static:\" );\n";
    PrintSectionDebug( $master_hash, $master_hash->{$type}->{static}, $type, $FHD );
    print $FHD "\n";

    print $FHD "    if ( object_status(id) == GIGO && ! object_init(id) )\n";
    print $FHD "    {\n";
    print $FHD "        cerr << \"Warning: Object \" << id << \" type $type not firing as it hasn't initialised and it's GIGO.\" << endl;\n";
    print $FHD "        return;\n";
    print $FHD "    }\n";
    print $FHD "\n";

    my $var_name;

    print $FHD "    if ( ";

    foreach $var_name ( @{$master_hash->{$type}->{sub}->{order}} ) {

        if ( PreComp::Utilities::IsArray( $var_name ) ) {

            my $var_name_stripped = PreComp::Utilities::StripBrackets( $var_name );

            my $size = PreComp::Utilities::GetArraySize( $master_hash, $var_name );

            my $counter=0;

            while ( $counter < $size ) {

                print $FHD "((((t4::$type*)obj_loc[id])->$var_name_stripped"."[$counter]) and object_status(((t4::$type*)obj_loc[id])->$var_name_stripped"."[$counter]) >= GIGO ) ||\n         ";
                $counter = $counter+1;
            }
        }
        else {
            print $FHD "( ((t4::$type*)obj_loc[id])->$var_name != id and object_status(((t4::$type*)obj_loc[id])->$var_name) >= GIGO ) ||\n        ";
        }

    }

    print $FHD "0 )\n";
    print $FHD "    {\n";
    print $FHD "        cerr << \"Warning: Object \" << id << \" not firing as one or more sub objects are GIGO.\" << endl;\n";
    print $FHD "\n";
    print $FHD "        if ( ! object_init(id) )\n";
    print $FHD "        {\n";
    print $FHD "            cerr << \"Error: Object \" << id << \" setting to GIGO as one or more sub objects are GIGO and the object hasn't initialised.\" << endl;\n";
    print $FHD "            object_status(id) = GIGO;\n";
    print $FHD "        }\n";
    print $FHD "        else if ( object_status(id) == OK )\n";
    print $FHD "        {\n";
    print $FHD "            cerr << \"Warning: Object \" << id << \" setting to STALE.\" << endl;\n";
    print $FHD "            object_status(id) = STALE;\n";
    print $FHD "        }\n";
    print $FHD "\n";
    print $FHD "        return;\n";
    print $FHD "    }\n";
    print $FHD "\n";



    print $FHD "\n";

    print $FHD "    if ( ! calculate_$type( obj_loc, id ) )\n";
    print $FHD "    {\n";
    print $FHD "        object_status(id) = GIGO;\n";
    print $FHD "        cerr << \"Error: Object \" << id << \" is GIGO as it failed calculation.\" << endl;\n";
    print $FHD "    }\n";
    print $FHD "    else\n";
    print $FHD "    {\n";

    print $FHD "        if ( ";

    foreach $var_name ( @{$master_hash->{$type}->{sub}->{order}} ) {

        if ( PreComp::Utilities::IsArray( $var_name ) ) {

            my $var_name_stripped = PreComp::Utilities::StripBrackets( $var_name );

            my $size = PreComp::Utilities::GetArraySize( $master_hash, $var_name );

            my $counter=0;

            while ( $counter < $size ) {

                print $FHD "((((t4::$type*)obj_loc[id])->$var_name_stripped"."[$counter]) and object_status(((t4::$type*)obj_loc[id])->$var_name_stripped"."[$counter]) == STALE ) ||\n             ";
                $counter = $counter+1;
            }
        }
        else {
            print $FHD "object_status(((t4::$type*)obj_loc[id])->$var_name) == STALE ||\n            ";
        }

    }

    print $FHD "0 )\n";
    print $FHD "        {\n";
    print $FHD "            cerr << \"Error: Object \" << id << \" is STALE.\" << endl;\n";
    print $FHD "            object_status(id) = STALE;\n";
    print $FHD "        }\n";
    print $FHD "        else \n";
    print $FHD "        {\n";
    print $FHD "            object_status(id) = OK;\n";
    print $FHD "            object_init(id) = 1;\n";
    print $FHD "        }\n";
    print $FHD "    }\n";


    print $FHD "\n";

    print $FHD "    DEBUG_FINE( \"pub:\" );\n";
    PrintSectionDebug( $master_hash, $master_hash->{$type}->{pub}, $type, $FHD );

    print $FHD "\n";
    print $FHD "}\n";
}

sub PrintSectionDebug($$$$) {
    my $master_hash = shift;
    my $section_hash = shift;
    my $stem = shift;
    my $FHD = shift;

    my ( $var_name, $var_type, $var_name_stripped );

    foreach $var_name ( @{$section_hash->{order}} ) {

        $var_type = $section_hash->{data}->{$var_name};
        $var_name_stripped = PreComp::Utilities::StripBrackets( $var_name );

        if ( exists $master_hash->{structures}->{data}->{$var_type} ) {

            print $FHD "    DEBUG_FINE( \"\\t$stem"."_$var_name_stripped: \" << &$stem"."_$var_name_stripped );\n";

        } 
        elsif ( PreComp::Utilities::IsArray( $var_name )) {

            my $size = PreComp::Utilities::GetArraySize( $master_hash, $var_name );

            my $counter=0;
            my $skipped=0;

            while ( $counter < $size ) {

                if ( $counter > 3 and $counter < $size - 4 ) {

                    if ( $skipped == 0 ) {

                        print $FHD "    DEBUG_FINE( \"\\t..skipping rows..\" );\n";

                        $skipped = 1;
                    }
                    
                    $counter = $counter+1;
                    next; 
                }
 
                print $FHD "    DEBUG_FINE( \"\\t$stem"."_$var_name_stripped"."[$counter]: \" << $stem"."_$var_name_stripped"."[$counter] );\n";

                $counter = $counter+1;
            }
        }
        else {

            print $FHD "    DEBUG_FINE( \"\\t$stem"."_$var_name: \" << $stem"."_$var_name );\n";

        }
    }
}

sub GenerateValidator($$$) {
    my $master_hash = shift;
    my $type = shift;
    my $FHD = shift;

    print $FHD "extern \"C\" int validate( obj_loc_t obj_loc, int id )\n";
    print $FHD "{\n";
    print $FHD "    int retval = 1;\n";

    my ( $var_name, $var_type );

    foreach $var_name ( @{$master_hash->{$type}->{sub}->{order}} ) {

        $var_type = $master_hash->{$type}->{sub}->{data}->{$var_name};

        if ( PreComp::Utilities::IsArray( $var_name ) ) {

            my $var_name_stripped = PreComp::Utilities::StripBrackets( $var_name );

            my $size = PreComp::Utilities::GetArraySize( $master_hash, $var_name );

            my $counter=0;

            while ( $counter < $size ) {

                print $FHD "    if ( ! obj_loc[((t4::$type*)obj_loc[id])->$var_name_stripped"."[$counter]] )\n";
                print $FHD "    {\n";
                print $FHD "        cout << \"Error: Type $type, id \" << id << \" failed validation because a sub object $var_name_stripped"."[$counter], id \" << ((t4::$type*)obj_loc[id])->$var_name_stripped"."[$counter] << \" does not exist.\" << endl;\n";
                print $FHD "        ((t4::$type*)obj_loc[id])->$var_name_stripped"."[$counter] = 0;\n";
                print $FHD "        retval = 0;\n";
                print $FHD "    }\n";
                print $FHD "\n";

                print $FHD "    if ( ((object_header*)obj_loc[((t4::$type*)obj_loc[id])->$var_name_stripped"."[$counter]])->implements != $master_hash->{$master_hash->{$var_type}->{implements}}->{type_id}  )\n";
                print $FHD "    {\n";

                print $FHD "        cout << \"Error: Type $type, id \" << id << \" failed validation because a sub object $var_name_stripped"."[$counter], id \" << ((t4::$type*)obj_loc[id])->$var_name_stripped"."[$counter] << \" is not of type $master_hash->{$master_hash->{$var_type}->{implements}}->{type_id}.\" << endl;\n";
                print $FHD "        ((t4::$type*)obj_loc[id])->$var_name_stripped"."[$counter] = 0;\n";
                print $FHD "        retval = 0;\n";
                print $FHD "    }\n";
                print $FHD "\n";

                $counter = $counter+1;
            }
        }
        else {

            print $FHD "    if ( ! obj_loc[((t4::$type*)obj_loc[id])->$var_name] )\n";
            print $FHD "    {\n";
            print $FHD "        cout << \"Error: Type $type, id \" << id << \" failed validation because a sub object $var_name, id \" << ((t4::$type*)obj_loc[id])->$var_name << \" does not exist.\" << endl;\n";
            print $FHD "        ((t4::$type*)obj_loc[id])->$var_name = 0;\n";
            print $FHD "        retval = 0;\n";
            print $FHD "    }\n";
            print $FHD "\n";

            print $FHD "    if ( ((object_header*)obj_loc[((t4::$type*)obj_loc[id])->$var_name])->implements != $master_hash->{$master_hash->{$var_type}->{implements}}->{type_id}  )\n";
            print $FHD "    {\n";

            print $FHD "        cout << \"Error: Type $type, id \" << id << \" failed validation because a sub object $var_name, id \" << ((t4::$type*)obj_loc[id])->$var_name << \" is not of type $master_hash->{$master_hash->{$var_type}->{implements}}->{type_id}.\" << endl;\n";
            print $FHD "        ((t4::$type*)obj_loc[id])->$var_name = 0;\n";
            print $FHD "        retval = 0;\n";
            print $FHD "    }\n";
            print $FHD "\n";

        }

    }

    print $FHD "    return retval;\n";
    print $FHD "}\n";

}

sub GenerateConcreteGraph($$$) {
    my $master_hash = shift;
    my $type = shift;
    my $FHD = shift;

    print $FHD "extern \"C\" void print_concrete_graph( obj_loc_t obj_loc, int id, ofstream& outfile )\n";
    print $FHD "{\n";
    print $FHD "    cout << \"Printing $type..\" << std::endl;\n";

    my $var_name;

    foreach $var_name ( @{$master_hash->{$type}->{sub}->{order}} ) {

        if ( PreComp::Utilities::IsArray( $var_name ) ) {

            my $var_name_stripped = PreComp::Utilities::StripBrackets( $var_name );

            my $size = PreComp::Utilities::GetArraySize( $master_hash, $var_name );

            my $counter=0;

            while ( $counter < $size ) {

                print $FHD " outfile << object_name(id) << \" -> \" << object_name(((t4::$type*)obj_loc[id])->$var_name_stripped"."[$counter]) << \" [dir=back] \" << endl;\n";

                $counter = $counter+1;
            }
        }
        else {

            print $FHD " outfile << object_name(id) << \" -> \" << object_name(((t4::$type*)obj_loc[id])->$var_name) << \" [dir=back] \" << endl;\n";

        }
    }

    print $FHD "\n";
    print $FHD "}\n";

}

1;

