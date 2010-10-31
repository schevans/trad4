#!/usr/bin/perl

# Copyright (c) Steve Evans 2007
# steve@topaz.myzen.co.uk
# This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

use warnings;
use strict;

use PreComp::AppConstants;
use PreComp::Utilities;

sub get_next_id();
sub generate_calendar();
sub generate_ir_curve();
sub generate_ir_curve_input_rates();
sub generate_bonds($);
sub generate_outright_trades($);
sub generate_repo_trades($);

my $current_id = 201;
my $log_level = 1;

my %discount_rate_ids;
my %bond_ccys;
my %fx_rates;
my @outright_agg;
my @repo_agg;
my @ir_curve_ids;

my @coup_pys = ( 1, 2, 4 );
my @currencies = ( 1, 2, 3 );
my @chars=( 'A'..'Z' );

if ( $#ARGV != 0 )
{
    print "generate_data.pl <directory>\n";
    exit 0;
}

my $constants_hash;

if (  -f $ENV{SRC_DIR}."/constants.t4s" ) {

    $constants_hash = PreComp::Utilities::LoadAppConstants();
}

my $NUM_FORWARD_DAYS = $constants_hash->{NUM_FORWARD_DAYS};
my $TODAY = 40403;

my $data_root=$ARGV[0];
my $outright_trades_file=$data_root."/outright_trades.sql";
my $repo_trades_file=$data_root."/repo_trades.sql";
my $fx_rate_file=$data_root."/fx_rates.sql";
my $discount_rate_file=$data_root."/discount_rate.sql";
my $interest_rate_file=$data_root."/interest_rate.sql";

if ( ! -d $data_root ) {

    `mkdir $data_root`;
}

my @bond_ids;
my %bond_to_ccy_curve;

generate_calendar();
generate_ir_curve();
generate_ir_curve_input_rates();

# small_set
generate_bonds( 5 );
generate_outright_trades( 9 );
#generate_repo_trades( 100000 );

# 220k
#generate_bonds( 20000 );
#generate_outright_trades( 100000 );
#generate_repo_trades( 100000 );

sub generate_calendar() {

    my $file = "$data_root/calendar.sql";
    open FILE, ">$file" or die "Can't open $file";

    print FILE "BEGIN;\n";

    print FILE "delete from calendar;\n";

    print FILE "insert into object values ( 1, 1, 1, \"calendar\", $log_level, 1 );\n";
    print FILE "insert into calendar values ( 1, $TODAY );\n";

    print FILE "COMMIT;\n";

    close FILE;

}


sub generate_ir_curve_input_rates() {

    my $file = "$data_root/ir_curve_input_rates.sql";
    open FILE, ">$file" or die "Can't open $file";

    print FILE "BEGIN;\n";

    print FILE "delete from ir_curve_input_rates;\n";

    my $id;
    foreach $id ( @ir_curve_ids ) {




        my $basis = (( $id / 10 ) - 1 ) / 10;

print "ID $id $basis\n";

        print FILE "insert into ir_curve_input_rates values ( $id, 0, ".(0.024+$basis).", 0 );\n";
        print FILE "insert into ir_curve_input_rates values ( $id, 1, ".(0.025+$basis).", 187 );\n";
        print FILE "insert into ir_curve_input_rates values ( $id, 2, ".(0.026+$basis).", 370 );\n";
        print FILE "insert into ir_curve_input_rates values ( $id, 3, ".(0.025+$basis).", 735 );\n";
        print FILE "insert into ir_curve_input_rates values ( $id, 4, ".(0.025+$basis).", 1465 );\n";
        print FILE "insert into ir_curve_input_rates values ( $id, 5, ".(0.024+$basis).", 2195 );\n";
        print FILE "insert into ir_curve_input_rates values ( $id, 6, ".(0.023+$basis).", 2925 );\n";
        print FILE "insert into ir_curve_input_rates values ( $id, 7, ".(0.023+$basis).", 3655 );\n";
        print FILE "insert into ir_curve_input_rates values ( $id, 8, ".(0.022+$basis).", 5480 );\n";
        print FILE "insert into ir_curve_input_rates values ( $id, 9, ".(0.022+$basis).", 7305 );\n";

    }

    print FILE "COMMIT;\n";

    close FILE;
}


sub generate_ir_curve() 
{

    my $file = "$data_root/ir_curve.sql";
    open FILE, ">$file" or die "Can't open $file";

    print FILE "BEGIN;\n";

    print FILE "delete from ir_curve;\n";

    my $id = 10;
    my $name = "LIBOR.USD";

    print FILE "insert into object values (  $id, 2, 1, \"$name\", $log_level, 1 );\n";
    print FILE "insert into ir_curve values ( $id );\n";

    push @ir_curve_ids, $id;

    $id++;
    $name = "LIBOR.GBP";

    print FILE "insert into object values (  $id, 2, 1, \"$name\", $log_level, 1 );\n";
    print FILE "insert into ir_curve values ( $id );\n";

    push @ir_curve_ids, $id;

print FILE "COMMIT;\n";
return;

    $id++;
    $name = "LIBOR.EUR";

    print FILE "insert into object values (  $id, 2, 1, \"$name\", $log_level, 1 );\n";
    print FILE "insert into ir_curve values ( $id );\n";

    push @ir_curve_ids, $id;

    print FILE "COMMIT;\n";

    close FILE;
}

sub generate_bonds($) {
    my $num_bonds = shift;

    my $file = "$data_root/bonds.sql";
    open FILE, ">$file" or die "Can't open $file";

    print FILE "BEGIN;\n";


    print FILE "delete from bond;\n";

    my ( $id, $name, $ir_curve );

    for ( my $i = 0 ; $i < $num_bonds ; $i++ ) {

        $id = get_next_id();
        $name = $chars[ int(rand( @chars )) ].$chars[ int(rand( @chars )) ].int( rand(999999999));

        $ir_curve = $ir_curve_ids[ int( rand( @ir_curve_ids )) ];

        print FILE "insert into object values (  $id, 3, 2, \"$name\", $log_level, 1 );\n";

        my $mat_date = $TODAY + int(rand( $NUM_FORWARD_DAYS )); 
        my $start_date = $mat_date - $NUM_FORWARD_DAYS;

        print FILE "insert into bond values (  $id, ".
            "$start_date,".
            "$mat_date,".
            $coup_pys[ int( rand( @coup_pys )) ].",".
            sprintf("%.2f", (rand( 2))).",".
            "1, ".
            $ir_curve.");\n";
            
        push @bond_ids, $id;
        $bond_to_ccy_curve{$id} = $ir_curve;
        $bond_ccys{$id} = $ir_curve;
    }
    print FILE "COMMIT;\n";

    close FILE;

}
                 
sub generate_outright_trades($) {
    my $num_outrignt_trades = shift;

    my $file = "$data_root/outright_trades.sql";
    open FILE, ">$file" or die "Can't open $file";

    print FILE "BEGIN;\n";

    print FILE "delete from outright_trade;\n";

    my ( $id, $name, $ir_curve );

    for ( my $i = 0 ; $i < $num_outrignt_trades ; $i++ ) {

        $id = get_next_id();

        $name = "0".int( rand(999999));

        print FILE "insert into object values (  $id, 4, 3, \"$name\", $log_level, 1 );\n";

        print FILE "insert into outright_trade values ( $id, ".
            sprintf("%.2f", 95.0 + (rand( 10 ))).", ".
            1000 * int( rand( 1000  )).", ".
            int( 8000 + rand(  99999 - 8000 )).", ".
            "0,".
            $bond_ids[ int( rand( @bond_ids )) ].");\n";

    }

    print FILE "COMMIT;\n";

    close FILE;

}

sub generate_repo_trades($) {
    my $num_objects = shift;

    my $file = "$data_root/repo_trades.sql";
    open FILE, ">$file" or die "Can't open $file";

    print FILE "BEGIN;\n";


    print FILE "delete from repo_trade;\n";

    my ( $id, $name, $ir_curve );

    for ( my $i = 0 ; $i < $num_objects ; $i++ ) {

        $id = get_next_id();

        my $name = "R".int( rand(999999));

        print FILE "insert into object values (  $id, 5, 3, \"$name\", $log_level, 1 );\n";

        my $cash_ccy = $currencies[ int( rand( @currencies )) ];
        my $notional = 10000 * int( rand( 100  ));
        my $bond = $bond_ids[ int( rand( @bond_ids )) ];
        my $bond_ccy = $bond_ccys{$bond};
        my $interest_rate = $bond_to_ccy_curve{$bond};

        my $fx_rate_key = "$cash_ccy"."$bond_ccy"; 
        my $fx_rate = $fx_rates{$fx_rate_key}; 

        print FILE "insert into repo_trade values ( $id, ". 
            sprintf("%.2f", (rand( 8 - 2 ) + 2)).",".
            "$cash_ccy,".
            int( 16000 + rand(  18000 - 16000 )).",".
            "0,".
            int( 8000 + rand(  99999 - 8000 )).",".
            $notional * int( sprintf("%.2f", 95.0 + (rand( 10 )))).",".
            "$notional,".
            int(rand(2)).",".
            $bond.",".
            $interest_rate.",".
            $fx_rate.
            ");\n";

    }

    print FILE "COMMIT;\n";

    close FILE;
}

sub get_next_id() {

    return $current_id++;

}

