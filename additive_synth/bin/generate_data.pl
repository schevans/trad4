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

my $NUM_HARMONICS=4;

print OUTFILE "BEGIN;\n";
print OUTFILE "delete from object;\n";
print OUTFILE "delete from harmonic;\n";
print OUTFILE "delete from mixer;\n";

for ( my $i=0 ; $i < $NUM_HARMONICS ; $i++ )
{
    my $harmonic_id = $harmonic_base_id + $i;

    print OUTFILE "insert into object values ( $harmonic_id, 1, 1, \"harmonic_$harmonic_id\", 1, 1 );\n";
    print OUTFILE "insert into harmonic values ( $harmonic_id );\n";

}

my $num_mixers=0;

for ( my $i=0 ; $i < $NUM_HARMONICS / 2 ; $i++ )
{
    my $mixer_id = $mixer_base_id + $i;

    print OUTFILE "insert into object values ( $mixer_id, 2, 2, \"mixer_$mixer_id\", 1, 1 );\n";

    print OUTFILE "insert into mixer values ( $mixer_id, 1 );\n";

my $h1id = ( $i * 2 ) + 1;
my $h2id = ( $i * 2 ) + 2;

print "M $mixer_id $h1id $h2id\n";

    print OUTFILE "insert into mixer_harmonics values ( $mixer_id, $h1id, $h2id );\n";
}

print OUTFILE "insert into object values ( 1002, 2, 3, \"mixer_1002\", 1, 1 );\n";

print OUTFILE "insert into mixer values ( 1002, 1 );\n";

print OUTFILE "insert into mixer_harmonics values ( 1002, 1000, 1001 );\n";

print OUTFILE "COMMIT;\n";

close OUTFILE;


