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
use PreComp::Enums;
use PreComp::AppConstants;

sub usage();
sub vprint($);

my %opts;

if ( ! getopts( 'o:hvck', \%opts ) ) {
    usage();
}

my $verbose = $opts{v};

if ( $opts{c} ) {

    PreComp::Utilities::Clean();
    exit 0;
}

if( $opts{h} ) {
    usage();
}

if( $opts{k} ) {
    PreComp::Utilities::SetExitOnError( 0 );
}

my $struct_hash;

if (  -f $ENV{SRC_DIR}."/structures.t4s" ) {

    vprint("Loading structures..");
    $struct_hash = PreComp::Utilities::LoadStructures();
}

my $enum_hash;

if (  -f $ENV{SRC_DIR}."/enums.t4s" ) {

    vprint("Loading enums..");
    $enum_hash = PreComp::Utilities::LoadEnums();
}

my $constants_hash;

if (  -f $ENV{SRC_DIR}."/constants.t4s" ) {

    vprint("Loading constants..");
    $constants_hash = PreComp::Utilities::LoadAppConstants();
}

vprint("Loading t4 files..");
my $master_hash = PreComp::Utilities::LoadDefs();

#print Dumper( $constants_hash );
#print "----------------------------\n";
#print Dumper( $struct_hash );

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

my $type;

vprint("Validating..");

foreach $type ( keys %doing ) {

    PreComp::Utilities::Validate( $master_hash, $type, $struct_hash, $enum_hash );
}

foreach $type ( keys %doing ) {

    vprint("Generating $type..");
    PreComp::Header::Generate( $master_hash->{$type} );
    PreComp::Wrapper::Generate( $master_hash, $type, $struct_hash, $constants_hash );
    PreComp::Sql::Generate( $master_hash, $struct_hash, $type );
    PreComp::Calculate::Generate( $master_hash->{$type} );
}

vprint("Generating makefiles..");
PreComp::Makefiles::Generate( $master_hash );

vprint("Generating macros..");
PreComp::Macros::Generate( $master_hash, $struct_hash );

vprint("Generating sql..");
PreComp::SqlCommon::Generate( $master_hash );

if ( $struct_hash ) {

    vprint("Generating structures..");
    PreComp::Structures::Generate( $struct_hash );
}

if ( $enum_hash ) {

    vprint("Generating enums..");
    PreComp::Enums::Generate( $enum_hash );
}

if ( $constants_hash ) {

    vprint("Generating constants..");
    PreComp::AppConstants::Generate( $constants_hash );
}

# Hack alert
`touch $ENV{APP_ROOT}/gen/objects/structures.h`;
`touch $ENV{APP_ROOT}/gen/objects/enums.h`;
`touch $ENV{APP_ROOT}/gen/objects/constants.h`;
`touch $ENV{APP_ROOT}/objects/common.h`;

if ( ! -f "$ENV{APP_ROOT}/objects/main.c" ) {

    vprint("Generating main..");
    open MAIN, ">$ENV{APP_ROOT}/objects/main.c" or die "Can't open $ENV{APP_ROOT}/objects/main.c";

    print MAIN "#include \"trad4.h\"\n";
    print MAIN "\n";
    print MAIN "int main()\n";
    print MAIN "{\n";
    print MAIN "    run_trad4();\n";
    print MAIN "}\n";

}

if ( ! -d "$ENV{APP_ROOT}/bin" ) {

    `mkdir $ENV{APP_ROOT}/bin`;
}

vprint("Done.");

sub usage() {

    print "Usage: precomp.pl [OPTION]\n";
    print "The trad4 precompiler.\n";
    print"\n";
    print "  -o <object>    precompile <object> only\n";
    print "  -k             continue on error\n";
    print "  -c             remove all generated files\n";
    print "  -v             verbose\n";
    print "  -h             display this help and exit\n";
    print"\n";

    exit 0;
}


sub vprint($) {
    my $str = shift;

    if ( $verbose ) {

        print "$str\n";
    }
}
