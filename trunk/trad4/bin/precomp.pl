#!/usr/bin/perl

use warnings;
use strict;

use PreComp::Calculate;
use PreComp::Header;
use PreComp::Wrapper;
use PreComp::Utilities;
use PreComp::Sql;
use PreComp::SqlCommon;
use PreComp::Makefiles;
use PreComp::Macros;

my $master_hash = PreComp::Utilities::LoadDefs();

my $type;

foreach $type ( %{$master_hash} ) {

    PreComp::Utilities::Validate( $master_hash, $type );
    PreComp::Header::Generate( $master_hash->{$type} );
    PreComp::Wrapper::Generate( $master_hash->{$type} );
    PreComp::Sql::Generate( $master_hash, $type );
    PreComp::Calculate::Generate( $master_hash->{$type} );

}

PreComp::Makefiles::Generate( $master_hash );
PreComp::Macros::Generate( $master_hash );
PreComp::SqlCommon::Generate( $master_hash );

if ( ! -f "$ENV{INSTANCE_ROOT}/objects/main.c" ) {

    open MAIN, ">$ENV{INSTANCE_ROOT}/objects/main.c" or die "Can't open $ENV{INSTANCE_ROOT}/objects/main.c";

    print MAIN "#include \"trad4.h\"\n";
    print MAIN "\n";
    print MAIN "int main()\n";
    print MAIN "{\n";
    print MAIN "    run_trad4();\n";
    print MAIN "}\n";

}

