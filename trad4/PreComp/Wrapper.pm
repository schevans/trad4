
package PreComp::Wrapper;

use PreComp::Utilities;
use PreComp::Constants;
use Data::Dumper;

sub generate_loader($$);
sub generate_constructor($$);
sub generate_calculate($$);
sub generate_need_refresh($$);
sub generate_loader_callback($$);

sub Generate($) {
    my $obj_hash = shift;

    my $name = $obj_hash->{name};

    my @header = PreComp::Constants::CommomHeader();

    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::GenObjRoot()."$name"."_wrapper.c" );

    #print_licence_header( $FHD );

    print $FHD "\n";
    print $FHD "#include <iostream>\n";
    print $FHD "#include <sstream>\n";

    if ( %{$obj_hash->{data}->{static_vec}} ) {
        print $FHD "#include <vector>\n";
    }

    print $FHD "\n";
    print $FHD "\n";
    print $FHD "#include \"trad4.h\"\n";
    print $FHD "#include \"$name.h\"\n";
    print $FHD "#include \"$name"."_macros.h\"\n";

    foreach $key ( keys %{$obj_hash->{data}->{sub}} ) {

        print $FHD "#include \"$key.h\"\n";
    }


    print $FHD "\n";
    print $FHD "#include <sqlite3.h>\n";
    print $FHD "\n";
    print $FHD "\n";
    print $FHD "void calculate_$obj_hash->{name}( obj_loc_t obj_loc, int id );\n";

    if ( %{$obj_hash->{data}->{static_vec}} ) {

        print $FHD "void extra_loader( obj_loc_t obj_loc, int id, sqlite3* db );\n";
    }

    print $FHD "\n";
    print $FHD "using namespace std;\n";
    print $FHD "\n";


    generate_constructor( $obj_hash, $FHD );
    print $FHD "\n";

    generate_calculate( $obj_hash, $FHD );
    print $FHD "\n";

    generate_need_refresh( $obj_hash, $FHD );
    print $FHD "\n";

    generate_loader_callback( $obj_hash, $FHD );
    print $FHD "\n";

    generate_loader( $obj_hash, $FHD );
    print $FHD "\n";

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

sub generate_calculate($$)
{
    my $obj_hash = shift;
    my $FHD = shift;

    print $FHD "extern \"C\" void calculate( obj_loc_t obj_loc, int id )\n";
    print $FHD "{\n";
    print $FHD "    calculate_$obj_hash->{name}( obj_loc, id );\n";
    print $FHD "\n";
    print $FHD "}\n";

}

sub generate_need_refresh($$)
{
    my $obj_hash = shift;
    my $FHD = shift;

    my $name = $obj_hash->{name};

    print $FHD "extern \"C\" int need_refresh( obj_loc_t obj_loc, int id )\n";
    print $FHD "{\n";

    print $FHD "    DEBUG_FINE( \"$name"."_need_refresh( \" << id << \")\" )\n";

    print $FHD "\n";
    print $FHD "    int retval = ( (((object_header*)obj_loc[id])->status == RELOADED ) || ";


    print $FHD "(((object_header*)obj_loc[id])->status == STOPPED ) && ( ";

    foreach $key ( keys %{$obj_hash->{data}->{sub}} ) {

        print $FHD "( *(int*)obj_loc[id] < *(int*)obj_loc[(($name*)obj_loc[id])->$key] ) || ";


    }
    if ( $has_feed eq "in" ) {

                print $FHD "(*(int*)obj_loc[id] < ((($name*)obj_loc[id])->in)->last_published ) ||"

    }
    print $FHD " 0 ));\n";

    print $FHD "\n";
    print $FHD "    return retval;\n";
    print $FHD "\n";
    print $FHD "}\n";

}

sub generate_loader_callback($$)
{
    my $obj_hash = shift;
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
    print $FHD "    if ( is_new )\n";
    print $FHD "        (($name*)obj_loc[id])->status = STOPPED;\n";
    print $FHD "    else\n";
    print $FHD "        (($name*)obj_loc[id])->status = RELOADED;\n";
    print $FHD "\n";
    print $FHD "    //(($name*)obj_loc[id])->calculator_fpointer = &calculate_$name"."_wrapper;\n";
    print $FHD "    //(($name*)obj_loc[id])->need_refresh_fpointer = &$name"."_need_refresh;\n";
    print $FHD "    (($name*)obj_loc[id])->type = ".$obj_hash->{type_num}.";\n";
    print $FHD "    memcpy( (($name*)obj_loc[id])->name, row[1], 32 );\n";
    print $FHD "    (($name*)obj_loc[id])->tier = atoi(row[2]);\n";
    print $FHD "    \n";

    if ( $has_feed ) {

        print $FHD "    (($name*)obj_loc[id])->shmid = create_shmem( \&tmp, sizeof( $name"."_$has_feed ) );;\n";
        print $FHD "    (($name*)obj_loc[id])->$has_feed = ($name"."_$has_feed*)tmp;\n";
        print $FHD "    ((($name*)obj_loc[id])->$has_feed)->last_published = 0;\n";

    }

    my $counter=4;


    foreach $key ( keys %{$obj_hash->{data}->{static}} ) {

        print $FHD "    (($name*)obj_loc[id])->$key = ";
        print $FHD PreComp::Utilities::Type2atoX($obj_hash->{data}->{static}->{$key})."(row[$counter]);\n";
        $counter++
    }

    foreach $key ( keys %{$obj_hash->{data}->{feed_in}} ) {

        print $FHD "    (($name*)obj_loc[id])->$key = ";
        print $FHD PreComp::Utilities::Type2atoX($obj_hash->{data}->{feed_in}->{$key})."(row[$counter]);\n";
        $counter++
    }

    foreach $key ( keys %{$obj_hash->{data}->{sub}} ) {

        print $FHD "    (($name*)obj_loc[id])->$key = ";
        print $FHD PreComp::Utilities::Type2atoX($obj_hash->{data}->{sub}->{$key})."(row[$counter]);\n";
        $counter++
    }

    print $FHD "\n";
    print $FHD "    //calculate_$name"."_wrapper((void*)id);\n";

    print $FHD "\n";
    print $FHD "\n";

    print $FHD "    if ( is_new )\n";
    print $FHD "    {\n";
    print $FHD "        //tier_manager[$obj_hash->{tier}][tier_manager[$obj_hash->{tier}][0]] = id;\n";
    print $FHD "        //tier_manager[$obj_hash->{tier}][0]++;\n";
    print $FHD "\n";
    print $FHD "        std::cout << \"New $name created.\" << std::endl;\n";
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
    print $FHD "extern \"C\" void load_objects( obj_loc_t obj_loc, tier_manager_t tier_manager )\n";
    print $FHD "{\n";
    print $FHD "    std::cout << \"load_all_$name"."s()\" << std::endl;\n";
    print $FHD "\n";
    print $FHD "    char *zErrMsg = 0;\n";
    print $FHD "    sqlite3* db;\n";
    print $FHD "    sqlite3_open(getenv(\"TRAD4_DB\"), &db);\n";
    print $FHD "\n";
    print $FHD "    std::ostringstream dbstream;\n";
    print $FHD "    dbstream << \"select o.id, o.name, ot.tier, o.log_level ";

    foreach $key ( keys %{$obj_hash->{data}->{static}} ) {
        print $FHD ", t.$key ";
    }

    foreach $key ( keys %{$obj_hash->{data}->{feed_in}} ) {
        print $FHD ", t.$key ";
    }

    foreach $key ( keys %{$obj_hash->{data}->{sub}} ) {
        print $FHD ", t.$key ";
    }

    print $FHD " from object o, object_types ot";

    if ( %{$obj_hash->{data}->{static}} or %{$obj_hash->{data}->{feed_in}} or %{$obj_hash->{data}->{sub}} ) {
        print $FHD ", $name t ";
    }

    print $FHD " where ";

    if ( %{$obj_hash->{data}->{static}} or %{$obj_hash->{data}->{feed_in}} or %{$obj_hash->{data}->{sub}} ) {
        print $FHD " o.id = t.id and ";

    }
    print $FHD " o.type = ot.type_id and o.type = ".$obj_hash->{type_num}." and o.need_reload=1\";\n";


    print $FHD "\n";
    print $FHD "    if( sqlite3_exec(db, dbstream.str().c_str(), load_objects_callback, obj_loc, &zErrMsg) != SQLITE_OK ){\n";
    print $FHD "        fprintf(stderr, \"SQL error: %s\\n\", zErrMsg);\n";
    print $FHD "        sqlite3_free(zErrMsg);\n";
    print $FHD "    }\n";
    print $FHD "\n";

    if ( $has_feed ) {
        print $FHD "     void* tmp;\n";
        print $FHD "\n";
    }

    if ( %{$obj_hash->{data}->{static_vec}} ) {

        print $FHD "\n";
        print $FHD "    for ( int i = 0 ; i < MAX_OBJECTS+1 ; i++ )\n";
        print $FHD "    {\n";
        print $FHD "        if ( obj_loc[i] && ((object_header*)obj_loc[i])->type == 1 && ((object_header*)obj_loc[i])->status == RELOADED)\n";
        print $FHD "        {\n";
        print $FHD "            extra_loader( obj_loc, i, db );\n";
        print $FHD "        }\n";
        print $FHD "    }\n";
        print $FHD "\n";
        print $FHD "\n";
    }

    print $FHD "}\n";

    print $FHD "\n";

}


1;

