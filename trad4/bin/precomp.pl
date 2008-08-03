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
use PreComp::Structures;

sub usage();

my %opts;

our( $opt_h, $opt_k, $opt_c, $opt_o );

if ( ! getopts( 'hko:c', \%opts ) ) {
    usage();
}

if ( $opt_c ) {

    PreComp::Utilities::Clean();
    exit 0;
}

if( $opt_h ) {
    usage();
}

if( $opt_k ) {
    PreComp::Utilities::SetExitOnError( 0 );
}

my $struct_hash;

if (  -f $ENV{APP_ROOT}."/defs/structures.t4s" ) {

    $struct_hash = PreComp::Utilities::LoadStructures();
}

my $master_hash = PreComp::Utilities::LoadDefs();

my %doing;

if ( $opts{o} ) {

    if ( $master_hash->{$opts{o}} ) {
        $doing{$opts{o}} = 1;
    }
    else {
    
        print "Error: Type $opts{o} not found. Exiting.\n";
        exit(1);
    }
}
else {

    my $key;

    foreach $key ( keys %{$master_hash} ) {

        $doing{$key} = 1;
    }
}

#print Dumper( $master_hash );

my $type;

foreach $type ( keys %doing ) {

    if ( ! PreComp::Utilities::Validate( $master_hash, $type ) ) {
        PreComp::Utilities::ExitOnError();
    }
}

foreach $type ( keys %doing ) {

    PreComp::Header::Generate( $master_hash->{$type} );
    PreComp::Wrapper::Generate( $master_hash->{$type}, $struct_hash );
    PreComp::Sql::Generate( $master_hash, $struct_hash, $type );
    PreComp::Calculate::Generate( $master_hash->{$type} );
}

PreComp::Makefiles::Generate( $master_hash );
PreComp::Macros::Generate( $master_hash, $struct_hash );
PreComp::SqlCommon::Generate( $master_hash );
PreComp::Structures::Generate( $struct_hash );

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
    print "  -o <object>    precompile <object> only\n";
    print "  -k             continue on error\n";
    print "  -c             remove all generated files\n";
    print "  -h             display this help and exit\n";
    print"\n";

    exit 0;
}


