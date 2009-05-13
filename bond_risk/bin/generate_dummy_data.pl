#!/usr/bin/perl

# Copyright (c) Steve Evans 2007
# steve@topaz.myzen.co.uk
# This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

use warnings;
use strict;

sub get_next_id();
sub generate_currency_curves_ir_rates();
sub generate_currency_curves();
sub generate_fx_rates();
sub generate_bonds($);
sub generate_outright_trades($);
sub generate_repo_trades($);
sub generate_object($$);

my $current_id = 201;


my %discount_rate_ids;
my %bond_ccys;
my %fx_rates;
my @outright_agg;
my @repo_agg;
my @currency_curve_ids;

my @coup_pys = ( 1, 2, 4 );
my @currencies = ( 1, 2, 3 );
my @chars=( 'A'..'Z' );

my $dummy_data_root="$ENV{APP_ROOT}/data/dummy_data";
my $outright_trades_file=$dummy_data_root."/dummy_outright_trades.sql";
my $repo_trades_file=$dummy_data_root."/dummy_repo_trades.sql";
my $fx_rate_file=$dummy_data_root."/dummy_fx_rates.sql";
my $discount_rate_file=$dummy_data_root."/dummy_discount_rate.sql";
my $interest_rate_file=$dummy_data_root."/dummy_interest_rate.sql";

if ( ! -d $dummy_data_root ) {

    `mkdir $dummy_data_root`;
}

my @bond_ids;
my %bond_to_ccy_curve;

generate_currency_curves_ir_rates();
generate_currency_curves();
generate_fx_rates();
generate_bonds( 20000 );
generate_outright_trades( 100000 );
generate_repo_trades( 100000 );

sub generate_currency_curves_ir_rates() {

    my $id = 1;
    my $file = "$dummy_data_root/currency_curves_ir_rates.sql";
    open FILE, ">$file" or die "Can't open $file";

    print FILE "BEGIN;\n";

    print FILE "delete from currency_curves_ir_rates;\n";

    print FILE "insert into currency_curves_ir_rates values ( $id, 0, 10000,2.6 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 1, 10010,2.7 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 2, 10100,2.7 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 3, 10200,2.7 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 4, 10300,2.8 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 5, 12000,2.8 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 6, 13000,2.9 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 7, 15000,2.9 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 8, 18000,2.8 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 9, 20000,2.8 );\n";

    $id = 2;

    print FILE "insert into currency_curves_ir_rates values ( $id, 0, 10000,5.2 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 1, 10010,5.3 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 2, 10100,5.4 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 3, 10200,5.4 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 4, 10300,5.5 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 5, 12000,5.5 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 6, 13000,5.5 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 7, 15000,5.4 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 8, 18000,5.3 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 9, 20000,5.3 );\n";

    $id = 3;

    print FILE "insert into currency_curves_ir_rates values ( $id, 0, 10000,3.6 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 1, 10010,3.7 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 2, 10100,3.7 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 3, 10200,3.7 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 4, 10300,3.8 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 5, 12000,3.8 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 6, 13000,3.9 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 7, 15000,3.9 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 8, 18000,3.8 );\n";
    print FILE "insert into currency_curves_ir_rates values ( $id, 9, 20000,3.8 );\n";

    print FILE "COMMIT;\n";

    close FILE;
}


sub generate_currency_curves() 
{

    my $file = "$dummy_data_root/currency_curves.sql";
    open FILE, ">$file" or die "Can't open $file";

    print FILE "BEGIN;\n";

    print FILE "delete from currency_curves;\n";

    my $id = 1;
    my $name = "USD-CCY-CURVES";
    my $interest_rate = 1;

    print FILE "insert into object values (  $id, 1, 1, \"$name\", 0, 1 );\n";
    print FILE "insert into currency_curves values ( $id );\n";

    push @currency_curve_ids, $id;

    $id = 2;
    $name = "GBP-CCY-CURVES";
    $interest_rate = 2;

    print FILE "insert into object values (  $id, 1, 1, \"$name\", 0, 1 );\n";
    print FILE "insert into currency_curves values ( $id );\n";

    push @currency_curve_ids, $id;

    $id = 3;
    $name = "EUR-CCY-CURVES";
    $interest_rate = 3;

    print FILE "insert into object values (  $id, 1, 1, \"$name\", 0, 1 );\n";
    print FILE "insert into currency_curves values ( $id );\n";

    push @currency_curve_ids, $id;

    print FILE "COMMIT;\n";

    close FILE;
}

sub generate_fx_rates() {

    my $file = "$dummy_data_root/fx_rates.sql";
    open FILE, ">$file" or die "Can't open $file";

    print FILE "BEGIN;\n";

    print FILE "delete from fx_rate;\n";

    my $id = 4;
    my $name = "USD-GBP";
    print FILE "insert into object values (  $id, 2, 1, \"$name\", 0, 1 );\n";
    print FILE "insert into fx_rate values ( $id, 0.509242756, 1, 2 );\n";
    $fx_rates{12} = $id;

    $id = 5;
    $name = "GBP-EUR";
    print FILE "insert into object values (  $id, 2, 1, \"$name\", 0, 1 );\n";
    print FILE "insert into fx_rate values ( $id, 1.4734749, 2, 3 );\n";
    $fx_rates{23} = $id;

    $id = 6;
    $name = "EUR-USD";
    print FILE "insert into object values (  $id, 2, 1, \"$name\", 0, 1 );\n";
    print FILE "insert into fx_rate values ( $id, 1.3327, 3, 1 );\n";
    $fx_rates{31} = $id;

    $id = 7;
    $name = "GBP-USD";
    print FILE "insert into object values (  $id, 2, 1, \"$name\", 0, 1 );\n";
    print FILE "insert into fx_rate values ( $id, ".(1.0/0.509242756).", 2, 1 );\n";
    $fx_rates{21} = $id;

    $id = 8;
    $name = "EUR-GBP";
    print FILE "insert into object values (  $id, 2, 1, \"$name\", 0, 1 );\n";
    print FILE "insert into fx_rate values ( $id, ".(1.0/1.4734749).", 3, 2 );\n";
    $fx_rates{32} = $id;

    $id = 10;
    $name = "USD-EUR";
    print FILE "insert into object values (  $id, 2, 1, \"$name\", 0, 1 );\n";
    print FILE "insert into fx_rate values ( $id, ".(1.0/1.3327).", 1, 3 );\n";
    $fx_rates{13} = $id;

    $id = 11;
    $name = "USD-USD";
    print FILE "insert into object values (  $id, 2, 1, \"$name\", 0, 1 );\n";
    print FILE "insert into fx_rate values ( $id, 1.0, 1, 1 );\n";
    $fx_rates{11} = $id;

    $id = 12;
    $name = "GBP-GBP";
    print FILE "insert into object values (  $id, 2, 1, \"$name\", 0, 1 );\n";
    print FILE "insert into fx_rate values ( $id, 1.0, 2, 2 );\n";
    $fx_rates{22} = $id;

    $id = 13;
    $name = "EUR-EUR";
    print FILE "insert into object values (  $id, 2, 1, \"$name\", 0, 1 );\n";
    print FILE "insert into fx_rate values ( $id, 1.0, 3, 3 );\n";
    $fx_rates{33} = $id;
    
    print FILE "COMMIT;\n";

    close FILE;
}

sub generate_bonds($) {
    my $num_bonds = shift;

    my $file = "$dummy_data_root/bonds.sql";
    open FILE, ">$file" or die "Can't open $file";

    print FILE "BEGIN;\n";


    print FILE "delete from bond;\n";

    my ( $id, $name, $currency_curve );

    for ( my $i = 0 ; $i < $num_bonds ; $i++ ) {

        $id = get_next_id();
        $name = $chars[ int(rand( @chars )) ].$chars[ int(rand( @chars )) ].int( rand(999999999));

        $currency_curve = $currency_curve_ids[ int( rand( @currency_curve_ids )) ];

        print FILE "insert into object values (  $id, 3, 2, \"$name\", 0, 1 );\n";

        print FILE "insert into bond values (  $id, ".
            int( 6000 + rand(  8000 - 6000 )).",".
            int( 18000 + rand( 20000 - 18000 )).",".
            $coup_pys[ int( rand( @coup_pys )) ].",".
            sprintf("%.2f", (rand( 2))).",".
            $currency_curve.");\n";
            
        push @bond_ids, $id;
        $bond_to_ccy_curve{$id} = $currency_curve;
        $bond_ccys{$id} = $currency_curve;
    }
    print FILE "COMMIT;\n";

    close FILE;

}
                 
sub generate_outright_trades($) {
    my $num_outrignt_trades = shift;

    my $file = "$dummy_data_root/outright_trades.sql";
    open FILE, ">$file" or die "Can't open $file";

    print FILE "BEGIN;\n";


    print FILE "delete from outright_trade;\n";

    my ( $id, $name, $currency_curve );

    for ( my $i = 0 ; $i < $num_outrignt_trades ; $i++ ) {

        $id = get_next_id();

        $name = "C".int( rand(999999));

        print FILE "insert into object values (  $id, 4, 3, \"$name\", 0, 1 );\n";

        print FILE "insert into outright_trade values ( $id, ".
            1000 * int( rand( 1000  )).",".
            int( 8000 + rand(  99999 - 8000 )).",".
            sprintf("%.2f", 95.0 + (rand( 10 ))).",".
            "0,".
            $bond_ids[ int( rand( @bond_ids )) ].");\n";

    }

    print FILE "COMMIT;\n";

    close FILE;

}

sub generate_repo_trades($) {
    my $num_objects = shift;

    my $file = "$dummy_data_root/repo_trades.sql";
    open FILE, ">$file" or die "Can't open $file";

    print FILE "BEGIN;\n";


    print FILE "delete from repo_trade;\n";

    my ( $id, $name, $currency_curve );

    for ( my $i = 0 ; $i < $num_objects ; $i++ ) {

        $id = get_next_id();

        my $name = "R".int( rand(999999));

        print FILE "insert into object values (  $id, 5, 3, \"$name\", 0, 1 );\n";

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

