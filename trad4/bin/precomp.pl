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
use PreComp::Aliases;
use PreComp::Docco;

sub usage();

my %opts;

if ( ! getopts( 'o:hvdckan', \%opts ) ) {
    usage();
}

my $verbose = $opts{v};

if ( $opts{c} ) {

    PreComp::Utilities::Clean();
    exit 0;
}

if ( $opts{a} ) {

    PreComp::Utilities::Clean();
}

if( $opts{h} ) {
    usage();
}

if( $opts{k} ) {
    PreComp::Utilities::SetExitOnError( 0 );
}

my $struct_hash;

if ( -f $ENV{SRC_DIR}."/structures.t4s" ) {

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

my $alias_hash;

if ( -f  $ENV{SRC_DIR}."/aliases.t4s" ) {

    print "Loading aliases..\n";
    $alias_hash = PreComp::Utilities::LoadAliases();
}

print "Loading t4 files..\n";
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

my $type;

my $new_master_hash = PreComp::Utilities::UpgradeMasterHash( $master_hash, $struct_hash, $enum_hash, $alias_hash, $constants_hash );

if ( $verbose ) {

    if ( $opts{o} ) {

        foreach $type ( keys %doing ) {

            my $header_string = "Type $type:";

            print "$header_string\n";

            my $counter = 0;

            while ( $counter < length( $header_string ) ) {

                print "-";
                $counter = $counter + 1;
            }
            print "\n"; 

            print Dumper( $new_master_hash->{$type} );
            print "\n";

        }
    }
    else {

        print "Master hash:\n";
        print "------------\n";
        print Dumper( $new_master_hash );
        print "\n";
    }
}

print "Validating..\n";

foreach $type ( keys %doing ) {

    PreComp::Utilities::Validate( $new_master_hash, $type );
}

PreComp::Structures::Validate( $new_master_hash );

foreach $type ( keys %doing ) {

    print "Generating $type..\n";
    PreComp::Header::Generate( $master_hash->{$type} );
    PreComp::Wrapper::Generate( $master_hash, $type, $struct_hash, $constants_hash, $new_master_hash );
    PreComp::Calculate::Generate( $master_hash->{$type} );
    PreComp::Macros::Generate( $new_master_hash, $type );
    PreComp::Sql::Generate( $new_master_hash, $type );
}

print "Generating makefiles..\n";
PreComp::Makefiles::Generate( $master_hash );

print "Generating sql..\n";
PreComp::SqlCommon::Generate( $master_hash );

print "Generating structures..\n";
PreComp::Structures::Generate( $struct_hash );

print "Generating enums..\n";
PreComp::Enums::Generate( $enum_hash );

print "Generating constants..\n";
PreComp::AppConstants::Generate( $constants_hash );

print "Generating aliases..\n";
PreComp::Aliases::Generate( $alias_hash );

if( $opts{d} ) {

    print "Generating docco..\n";
    PreComp::Docco::Generate( $master_hash );

    PreComp::Docco::GenerateAbstractDiagram( $new_master_hash );
}

my $main_file = "$ENV{APP_ROOT}/objects/main.c";

if ( ! -f $main_file ) {

    print "Generating main..\n";

    my $FHD = PreComp::Utilities::OpenFile( $main_file );

    print $FHD "\n";
    print $FHD "#include \"trad4.h\"\n";
    print $FHD "\n";
    print $FHD "int main()\n";
    print $FHD "{\n";
    print $FHD "    run_trad4();\n";
    print $FHD "}\n";

    PreComp::Utilities::CloseFile();

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
    print "  -a             remove all generated files and regenerate\n";
    print "  -v             verbose - dumps internal structures\n";
    print "  -d             generate documentation\n";
    print "  -h             display this help and exit\n";
    print"\n";

    exit 0;
}


