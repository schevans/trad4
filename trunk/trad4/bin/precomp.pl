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

my %opts;

if ( ! getopts( 'o:hvsck', \%opts ) ) {
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

    print "Loading structures..\n";
    $struct_hash = PreComp::Utilities::LoadStructures();
}

my $enum_hash;

if (  -f $ENV{SRC_DIR}."/enums.t4s" ) {

    print "Loading enums..\n";
    $enum_hash = PreComp::Utilities::LoadEnums();
}

my $constants_hash;

if (  -f $ENV{SRC_DIR}."/constants.t4s" ) {

    print "Loading constants..\n";
    $constants_hash = PreComp::Utilities::LoadAppConstants();
}

print "Loading t4 files..\n";
my $master_hash = PreComp::Utilities::LoadDefs();

if ( $verbose ) {

    print Dumper( $constants_hash );
    print "----------------------------\n";
    print Dumper( $enum_hash );
    print "----------------------------\n";
    print Dumper( $struct_hash );
    print "----------------------------\n";
    print Dumper( $master_hash );
}

if ( $opts{s} ) {
    PreComp::Utilities::GenerateSpecs( $master_hash );
}

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

print "Validating..\n";

foreach $type ( keys %doing ) {

    PreComp::Utilities::Validate( $master_hash, $type, $struct_hash, $enum_hash );
}

foreach $type ( keys %doing ) {

    print "Generating $type..\n";
    PreComp::Header::Generate( $master_hash->{$type} );
    PreComp::Wrapper::Generate( $master_hash, $type, $struct_hash, $constants_hash );
    PreComp::Sql::Generate( $master_hash, $struct_hash, $type );
    PreComp::Calculate::Generate( $master_hash->{$type} );
}

print "Generating makefiles..\n";
PreComp::Makefiles::Generate( $master_hash );

print "Generating macros..\n";
PreComp::Macros::Generate( $master_hash, $struct_hash );
#PreComp::NewMacros::Generate( $master_hash );

print "Generating sql..\n";
PreComp::SqlCommon::Generate( $master_hash );

if ( $struct_hash ) {

    print "Generating structures..\n";
    PreComp::Structures::Generate( $struct_hash );
}

if ( $enum_hash ) {

    print "Generating enums..\n";
    PreComp::Enums::Generate( $enum_hash );
}

if ( $constants_hash ) {

    print "Generating constants..\n";
    PreComp::AppConstants::Generate( $constants_hash );
}

# Hack alert
`touch $ENV{APP_ROOT}/gen/objects/structures.h`;
`touch $ENV{APP_ROOT}/gen/objects/enums.h`;
`touch $ENV{APP_ROOT}/gen/objects/constants.h`;
`touch $ENV{APP_ROOT}/objects/common.h`;

if ( ! -f "$ENV{APP_ROOT}/objects/main.c" ) {

    print "Generating main..\n";
    open MAIN, ">$ENV{APP_ROOT}/objects/main.c" or die "Can't open $ENV{APP_ROOT}/objects/main.c";

    print MAIN "#include \"trad4.h\"\n";
    print MAIN "\n";
    print MAIN "int main()\n";
    print MAIN "{\n";
    print MAIN "    run_trad4();\n";
    print MAIN "}\n";

    close MAIN;

}

if ( ! -f "$ENV{APP_ROOT}/objects/printer.c" ) {

    print "Generating main..\n";
    open FILE, ">$ENV{APP_ROOT}/objects/printer.c" or die "Can't open $ENV{APP_ROOT}/objects/printer.c";

    print FILE "\n";
    print FILE "#include <iostream>\n";
    print FILE "#include \"trad4.h\"\n";
    print FILE "\n";
    print FILE "using namespace std;\n";
    print FILE "\n";
    print FILE "extern \"C\" void printer( obj_loc_t obj_loc )\n";
    print FILE "{\n";
    print FILE "    //cout << \"Printing..\" << endl;\n";
    print FILE "}\n";

    close FILE;
}


if ( ! -d "$ENV{APP_ROOT}/bin" ) {

    `mkdir $ENV{APP_ROOT}/bin`;
}

print "Done.\n";

sub usage() {

    print "Usage: precomp.pl [OPTION]\n";
    print "The trad4 precompiler.\n";
    print"\n";
    print "  -o <object>    precompile <object> only\n";
    print "  -k             continue on error\n";
    print "  -c             remove all generated files\n";
    print "  -v             verbose - dumps internal structures\n";
    print "  -s             generate specs\n";
    print "  -h             display this help and exit\n";
    print"\n";

    exit 0;
}


