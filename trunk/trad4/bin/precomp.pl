#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;
use Getopt::Std;

use PreComp::Calculate;
use PreComp::Header;
use PreComp::Wrapper;
use PreComp::Utilities;
use PreComp::Sql;
use PreComp::SqlCommon;
use PreComp::Makefiles;
use PreComp::Macros;

sub usage();

our( $opt_h, $opt_k );

if ( ! getopts( 'hk') ) {
    usage();
}

if( $opt_h ) {
    usage();
}

if( $opt_k ) {
    PreComp::Utilities::SetExitOnError( 0 );
}

my $master_hash = PreComp::Utilities::LoadDefs();

#print Dumper( $master_hash );

my $type;

foreach $type ( keys %{$master_hash} ) {

    if ( ! PreComp::Utilities::Validate( $master_hash, $type ) ) {
        PreComp::Utilities::ExitOnError();
    }
}

foreach $type ( keys %{$master_hash} ) {

    PreComp::Header::Generate( $master_hash->{$type} );
    PreComp::Wrapper::Generate( $master_hash->{$type} );
    PreComp::Sql::Generate( $master_hash, $type );
    PreComp::Calculate::Generate( $master_hash->{$type} );
}

PreComp::Makefiles::Generate( $master_hash );
PreComp::Macros::Generate( $master_hash );
PreComp::SqlCommon::Generate( $master_hash );

if ( ! -f "$ENV{APP_ROOT}/objects/main.c" ) {

    open MAIN, ">$ENV{APP_ROOT}/objects/main.c" or die "Can't open $ENV{APP_ROOT}/objects/main.c";

    print MAIN "#include \"trad4.h\"\n";
    print MAIN "\n";
    print MAIN "int main()\n";
    print MAIN "{\n";
    print MAIN "    run_trad4();\n";
    print MAIN "}\n";

}


sub usage() {

    print "Usage: precomp.pl [OPTION]\n";
    print "The trad4 precompiler.\n";
    print"\n";
    print "  -k             continue on error\n";
    print "  -h             display this help and exit\n";
    print"\n";

    exit 0;
}


