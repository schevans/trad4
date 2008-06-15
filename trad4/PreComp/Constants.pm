# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#


package PreComp::Constants;


sub SqlRoot { return "$ENV{INSTANCE_ROOT}/gen/sql/"; }
sub GenObjRoot { return "$ENV{INSTANCE_ROOT}/gen/objects/"; }
sub ObjRoot { return "$ENV{INSTANCE_ROOT}/objects/"; }

sub DefsRoot { return "$ENV{INSTANCE_ROOT}/defs/"; }

sub CommomHeader { 

    my @header = ( 
        "long_long last_published",
        "int id",
        "object_status status",
        "int type" ,
        "int tier" ,
        "char name[OBJECT_NAME_LEN]",
        "int log_level"
    );

    return @header;
}

1;
 
