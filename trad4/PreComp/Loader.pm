
package PreComp::Loader;

use PreComp::Utilities;
use PreComp::Constants;
use Data::Dumper;

sub Generate($) {
    my $obj_hash = shift;

    my $name = $obj_hash->{name};

    my @header = PreComp::Constants::CommomHeader();

    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::GenObjRoot()."load_$name.c" );


#    open $FHD, ">$gen_root/objects/$loader_filename" or die "Can't open $gen_root/objects/$loader_filename for writing. Exiting";

    #print_licence_header( $FHD );

    print $FHD "\n";
    print $FHD "#include <iostream>\n";
    print $FHD "#include <sstream>\n";
    print $FHD "\n";
    print $FHD "\n";
    print $FHD "#include \"trad4.h\"\n";
    print $FHD "#include \"$name.h\"\n";

    foreach $key ( keys %{$obj_hash->{data}->{sub}} ) {

        print $FHD "#include \"$key.h\"\n";
    }


    print $FHD "\n";
    print $FHD "#include \"mysql/mysql.h\"\n";
    print $FHD "\n";
    print $FHD "extern void* obj_loc[NUM_OBJECTS+1];\n";
    print $FHD "extern void* calculate_$name"."_wrapper( void* id );\n";
    print $FHD "extern int create_shmem( void** ret_mem, size_t pub_size );\n";
    print $FHD "extern void set_timestamp( int id );\n";
    print $FHD "extern bool $name"."_need_refresh( int id );\n";
    print $FHD "extern int tier_manager[NUM_TIERS+1][NUM_OBJECTS+1];\n";
    print $FHD "\n";
    print $FHD "using namespace std;\n";
    print $FHD "\n";
    print $FHD "void load_$name( MYSQL* mysql )\n";
    print $FHD "{\n";
    print $FHD "    std::cout << \"load_all_$name"."s()\" << std::endl;\n";
    print $FHD "\n";
    print $FHD "    MYSQL_RES *result;\n";
    print $FHD "    MYSQL_ROW row;\n";
    print $FHD "\n";
    print $FHD "    std::ostringstream dbstream;\n";
    print $FHD "    dbstream << \"select o.id, o.name, o.log_level ";

    foreach $key ( keys %{$obj_hash->{data}->{static}} ) {
        print $FHD ", t.$key ";
    }

    foreach $key ( keys %{$obj_hash->{data}->{feed_in}} ) {
        print $FHD ", t.$key ";
    }

    foreach $key ( keys %{$obj_hash->{data}->{sub}} ) {
        print $FHD ", t.$key ";
    }

    print $FHD " from object o ";

    if ( %{$obj_hash->{data}->{static}} or %{$obj_hash->{data}->{feed_in}} or %{$obj_hash->{data}->{sub}} ) {
        print $FHD ", $name t ";
    }

    print $FHD " where ";

    if ( %{$obj_hash->{data}->{static}} or %{$obj_hash->{data}->{feed_in}} or %{$obj_hash->{data}->{sub}} ) {
        print $FHD " o.id = t.id and ";

    }
    print $FHD " o.type = ".$obj_hash->{type_num}." and need_reload=1\";\n";


    print $FHD "\n";
    print $FHD "    if(mysql_query(mysql, dbstream.str().c_str()) != 0) {\n";
    print $FHD "        std::cout << __LINE__ << \": \" << mysql_error(mysql) << std::endl;\n";
    print $FHD "        exit(0);\n";
    print $FHD "    }\n";
    print $FHD "\n";
    print $FHD "    result = mysql_use_result(mysql);\n";
    print $FHD "\n";

    if ( $has_feed ) {
        print $FHD "     void* tmp;\n";
        print $FHD "\n";
    }

    print $FHD "    while (( row = mysql_fetch_row(result) ))\n";
    print $FHD "    {\n";
    print $FHD "        int id = atoi(row[0]);\n";
    print $FHD "\n";
    print $FHD "        bool is_new(false);\n";
    print $FHD "\n";
    print $FHD "        if ( !obj_loc[id] ) \n";
    print $FHD "        {\n";
    print $FHD "            obj_loc[id] = new $name;\n";
    print $FHD "            is_new = true;\n";
    print $FHD "        }\n";
    print $FHD "\n";
    print $FHD "        (($name*)obj_loc[id])->id = id;\n";
    print $FHD "        (($name*)obj_loc[id])->log_level = atoi(row[2]);\n";
    print $FHD "        (($name*)obj_loc[id])->last_published = 0;\n";
    print $FHD "\n";
    print $FHD "        if ( is_new )\n";
    print $FHD "            (($name*)obj_loc[id])->status = STOPPED;\n";
    print $FHD "        else\n";
    print $FHD "            (($name*)obj_loc[id])->status = RELOADED;\n";
    print $FHD "\n";
    print $FHD "        (($name*)obj_loc[id])->calculator_fpointer = &calculate_$name"."_wrapper;\n";
    print $FHD "        (($name*)obj_loc[id])->need_refresh_fpointer = &$name"."_need_refresh;\n";
    print $FHD "        (($name*)obj_loc[id])->type = ".$obj_hash->{type_num}.";\n";
    print $FHD "        memcpy( (($name*)obj_loc[id])->name, row[1], 32 );\n";
    print $FHD "        \n";

    if ( $has_feed ) {

        print $FHD "        (($name*)obj_loc[id])->shmid = create_shmem( \&tmp, sizeof( $name"."_$has_feed ) );;\n";
        print $FHD "        (($name*)obj_loc[id])->$has_feed = ($name"."_$has_feed*)tmp;\n";
        print $FHD "        ((($name*)obj_loc[id])->$has_feed)->last_published = 0;\n";

    }

    my $counter=3;


    foreach $key ( keys %{$obj_hash->{data}->{static}} ) {

        print $FHD "        (($name*)obj_loc[id])->$key = ";
        print $FHD PreComp::Utilities::Type2atoX($obj_hash->{data}->{static}->{$key})."(row[$counter]);\n";
        $counter++
    }

    foreach $key ( keys %{$obj_hash->{data}->{feed_in}} ) {

        print $FHD "        (($name*)obj_loc[id])->$key = ";
        print $FHD PreComp::Utilities::Type2atoX($obj_hash->{data}->{feed_in}->{$key})."(row[$counter]);\n";
        $counter++
    }

    foreach $key ( keys %{$obj_hash->{data}->{sub}} ) {

        print $FHD "        (($name*)obj_loc[id])->$key = ";
        print $FHD PreComp::Utilities::Type2atoX($obj_hash->{data}->{sub}->{$key})."(row[$counter]);\n";
        $counter++
    }

    print $FHD "\n";
    print $FHD "        //calculate_$name"."_wrapper((void*)id);\n";

    print $FHD "\n";
    print $FHD "\n";

    print $FHD "        if ( is_new )\n";
    print $FHD "        {\n";
    print $FHD "            tier_manager[$obj_hash->{tier}][tier_manager[$obj_hash->{tier}][0]] = id;\n";
    print $FHD "            tier_manager[$obj_hash->{tier}][0]++;\n";
    print $FHD "\n";
    print $FHD "            std::cout << \"New $name created.\" << std::endl;\n";
    print $FHD "        }\n";

    print $FHD "    }\n";
    print $FHD "\n";
    print $FHD "    mysql_free_result(result);\n";
    print $FHD "}\n";

    print $FHD "\n";
    PreComp::Utilities::CloseFile();

}


1;

