#!/usr/bin/perl

# Copyright (c) Steve Evans 2009
# steve@topaz.myzen.co.uk
# This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

use warnings;
use strict;

use Data::Dumper;

use PreComp::AppConstants;
use PreComp::Utilities;


my $constants_hash;

if (  -f $ENV{SRC_DIR}."/constants.t4s" ) {

    $constants_hash = PreComp::Utilities::LoadAppConstants();
}

my $amp_id=9999;

my %tier_id_hash;

my $NUM_HARMONICS = $constants_hash->{NUM_HARMONICS};
my $NUM_HARMONICS_PER_MIXER = $constants_hash->{NUM_HARMONICS_PER_MIXER};

my $outfile = $ENV{APP_ROOT}."/data/worked_example/gen.sql";
open OUTFILE, ">$outfile" or die "Can't open $outfile.\n";

print OUTFILE "BEGIN;\n";
print OUTFILE "delete from object;\n";
print OUTFILE "delete from harmonic;\n";
print OUTFILE "delete from harmonic_samples;\n";
print OUTFILE "delete from mixer;\n";
print OUTFILE "delete from mixer_samples;\n";
print OUTFILE "delete from amplifier;\n";

my $current_id=1;

my $tier = 1;

print "Generating $NUM_HARMONICS harmonics..\n";

for ( ; $current_id <= $NUM_HARMONICS ; $current_id++ )
{
    print OUTFILE "insert into object values ( $current_id, 1, 1, \"harmonic_$current_id\", 0, 1 );\n";
    print OUTFILE "insert into harmonic values ( $current_id, 1 );\n";

    print OUTFILE "insert into harmonic_samples values ( $current_id";

    for ( my $i=0 ; $i < $NUM_HARMONICS_PER_MIXER ; $i++ ) {

        print OUTFILE ", $current_id";
    }

    print OUTFILE " );\n";

    push @{$tier_id_hash{$tier}}, $current_id; 

}

my $digger = $NUM_HARMONICS;

while ( $digger != $NUM_HARMONICS_PER_MIXER ) {

    $tier++;

    if ( $digger % $NUM_HARMONICS_PER_MIXER == 0 ) {

        $digger = $digger / $NUM_HARMONICS_PER_MIXER;

        print "Generating $digger mixers on tier $tier..\n";

        for ( my $i=0 ; $i < $digger ; $i++ )
        {
            print OUTFILE "insert into object values ( $current_id, 2, $tier, \"mixer_$current_id\", 0, 1 );\n";

            print OUTFILE "insert into mixer values ( $current_id, 0 );\n";

            print OUTFILE "insert into mixer_samples values ( $current_id";

            my @sub_array = @{$tier_id_hash{$tier-1}};

            for ( my $j=0 ; $j < $NUM_HARMONICS_PER_MIXER ; $j++ ) {

                my $sub_index = ($i*$NUM_HARMONICS_PER_MIXER) + $j;
        
                my $sub_id = $sub_array[$sub_index];

                print OUTFILE ", $sub_id";
            }

            print OUTFILE " );\n";

            push @{$tier_id_hash{$tier}}, $current_id; 

            $current_id++;
        }
    }
    else {
        print "Error: Indivisible inputs\n";
        exit(0);

    }

}

print OUTFILE "\n";

print "Generating master mixer..\n";

$tier++;

print OUTFILE "insert into object values ( $current_id, 2, $tier, \"master\", 0, 1 );\n";
print OUTFILE "insert into mixer values ( $current_id, 0 );\n";
print OUTFILE "insert into mixer_samples values ( $current_id";

for ( my $i=0 ; $i < $NUM_HARMONICS_PER_MIXER ; $i++ ) {

    print OUTFILE ", ".(($current_id-$NUM_HARMONICS_PER_MIXER) + $i);
}

print OUTFILE " );\n";

print "Generating amplifier..\n";

$tier++;

print OUTFILE "insert into object values ( $amp_id, 3, $tier, \"amplifier\", 0, 1 );\n";
print OUTFILE "insert into amplifier values ( $amp_id, $current_id );\n";

print OUTFILE "COMMIT;\n";

close OUTFILE;

print "Done.\n";

