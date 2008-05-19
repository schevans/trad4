

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
        "int type" ,
        "char name[OBJECT_NAME_LEN]",
        "int log_level"
    );

    return @header;
}

1;
 
