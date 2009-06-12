# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#


package PreComp::Constants;


sub SqlRoot { return "$ENV{APP_ROOT}/gen/sql/"; }
sub GenObjRoot { return "$ENV{APP_ROOT}/gen/objects/"; }
sub ObjRoot { return "$ENV{APP_ROOT}/objects/"; }
sub DoccoRoot { return "$ENV{APP_ROOT}/docco/"; }

sub CommomHeader { 

    my @header = ( 
        "long_long last_published",
        "int id",
        "e_status status",
        "int type" ,
        "int tier" ,
        "char name[OBJECT_NAME_LEN]",
        "int log_level",
        "int implements",
        "int init"
    );

    return @header;
}

1;
 
