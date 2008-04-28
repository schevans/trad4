

package PreComp::Constants;


sub SqlRoot { return "$ENV{INSTANCE_ROOT}/gen/sql/"; }
sub GenObjRoot { return "$ENV{INSTANCE_ROOT}/gen/objects/"; }
sub ObjRoot { return "$ENV{INSTANCE_ROOT}/objects/"; }

sub DefsRoot { return "$ENV{INSTANCE_ROOT}/defs/"; }

sub CommomHeader { 

    my @header = ( 
        "ulong last_published",
        "int id",
        "object_status status",
        "void (*calculator_fpointer)(obj_loc_t,int)",
        "int (*need_refresh_fpointer)(obj_loc_t,int)",
        "int type" ,
        "char name[OBJECT_NAME_LEN]",
        "int log_level"
    );

    return @header;
}

1;
 
