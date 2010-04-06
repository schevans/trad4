#!/usr/bin/perl

# Copyright (c) Steve Evans 2009
# steve@topaz.myzen.co.uk
# This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

use warnings;
use strict;

my $outfile = $ENV{APP_ROOT}."/data/worked_example/gen.sql";
open OUTFILE, ">$outfile" or die "Can't open $outfile.\n";

my $harmonic_base_id = 1;
my $mixer_base_id = 1000;

my $NUM_HARMONICS=16;
my $NUM_HARMONICS_PER_MIXER=4;

print OUTFILE "BEGIN;\n";
print OUTFILE "delete from object;\n";
print OUTFILE "delete from harmonic;\n";
print OUTFILE "delete from mixer;\n";
print OUTFILE "delete from mixer_samples;\n";

for ( my $i=0 ; $i < $NUM_HARMONICS ; $i++ )
{
    my $harmonic_id = $harmonic_base_id + $i;

    print OUTFILE "insert into object values ( $harmonic_id, 1, 1, \"harmonic_$harmonic_id\", 1, 1 );\n";
    print OUTFILE "insert into harmonic values ( $harmonic_id, 0 );\n";

    print OUTFILE "insert into harmonic_samples values ( $harmonic_id, $harmonic_id, $harmonic_id, $harmonic_id, $harmonic_id );\n";
}

my $num_mixers=0;

for ( my $i=0 ; $i < $NUM_HARMONICS / $NUM_HARMONICS_PER_MIXER ; $i++ )
{
    my $mixer_id = $mixer_base_id + $i;

    print OUTFILE "insert into object values ( $mixer_id, 2, 2, \"mixer_$mixer_id\", 1, 1 );\n";

    print OUTFILE "insert into mixer values ( $mixer_id, 1 );\n";

my $h1id = ( $i * $NUM_HARMONICS_PER_MIXER ) + 1;
my $h2id = ( $i * $NUM_HARMONICS_PER_MIXER ) + 2;
my $h3id = ( $i * $NUM_HARMONICS_PER_MIXER ) + 3;
my $h4id = ( $i * $NUM_HARMONICS_PER_MIXER ) + 4;

print "M $i $mixer_id $h1id $h2id $h3id $h4id\n";

    print OUTFILE "insert into mixer_samples values ( $mixer_id, $h1id, $h2id, $h3id, $h4id );\n";
}

print OUTFILE "insert into object values ( 1004, 2, 3, \"master\", 1, 1 );\n";

print OUTFILE "insert into mixer values ( 1004, 1 );\n";

print OUTFILE "insert into mixer_samples values ( 1004, 1000, 1001, 1002, 1003 );\n";

print OUTFILE "COMMIT;\n";

close OUTFILE;


