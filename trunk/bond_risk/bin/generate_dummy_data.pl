#!/usr/bin/perl

# Copyright (c) Steve Evans 2007
# steve@topaz.myzen.co.uk
# This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

use warnings;
use strict;

sub get_next_id();
sub generate_interest_rates();
sub generate_currency_curves();
sub generate_fx_rates();
sub generate_books();
sub generate_bonds($);
sub generate_outright_trades($);
sub generate_repo_trades($);
sub generate_object($$);

my $current_id = 201;


my %discount_rate_ids;
my @interest_rate_ids;
my %interest_rate_ccys;
my %bond_ccys;
my %fx_rates;
my @outright_agg;
my @repo_agg;
my @currency_curve_ids;

my @coup_pys = ( 1, 2, 4 );
my @currencies = ( 1, 2, 3 );
my @chars=( 'A'..'Z' );

my $dummy_data_root="$ENV{DATA_DIR}";
my $outright_trades_file=$dummy_data_root."/dummy_outright_trades.sql";
my $repo_trades_file=$dummy_data_root."/dummy_repo_trades.sql";
my $fx_rate_file=$dummy_data_root."/dummy_fx_rates.sql";
my $discount_rate_file=$dummy_data_root."/dummy_discount_rate.sql";
my $interest_rate_file=$dummy_data_root."/dummy_interest_rate.sql";

my @bond_ids;
my %bond_to_ccy_curve;

generate_interest_rates();
generate_currency_curves();
#generate_fx_rates();
#generate_books();
generate_bonds( 400000 );
generate_outright_trades( 400000 );
generate_repo_trades( 200000 );

sub generate_interest_rates() {

    my $id = 1;
    my $file = "$dummy_data_root/interest_rate_feeds.sql";
    open FILE, ">$file" or die "Can't open $file";

    print FILE "delete from object;\n";
    print FILE "delete from interest_rate_feed_data;\n";

    print FILE "insert into object values ( $id, 1, \"LIBOR-USD\");\n";

    print FILE "insert into interest_rate_feed_data values ( $id, 10000,2.6 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 10010,2.7 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 10100,2.7 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 10200,2.7 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 10300,2.8 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 12000,2.8 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 13000,2.9 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 15000,2.9 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 18000,2.8 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 20000,2.8 );\n";

    push @interest_rate_ids, $id;
    $interest_rate_ccys{$id} = $id;
    
    $id = 2;

    print FILE "insert into object values (  $id, 1, \"LIBOR-GBP\" );\n";

    print FILE "insert into interest_rate_feed_data values ( $id, 10000,5.2 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 10010,5.3 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 10100,5.4 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 10200,5.4 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 10300,5.5 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 12000,5.5 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 13000,5.5 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 15000,5.4 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 18000,5.3 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 20000,5.3 );\n";

    push @interest_rate_ids, $id;
    $interest_rate_ccys{$id} = $id;

    $id = 3;
    print FILE "insert into object values (  $id, 1, \"LIBOR-EUR\" );\n";

    print FILE "insert into interest_rate_feed_data values ( $id, 10000,3.6 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 10010,3.7 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 10100,3.7 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 10200,3.7 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 10300,3.8 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 12000,3.8 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 13000,3.9 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 15000,3.9 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 18000,3.8 );\n";
    print FILE "insert into interest_rate_feed_data values ( $id, 20000,3.8 );\n";

    push @interest_rate_ids, $id;
    $interest_rate_ccys{$id} = $id;

    close FILE;
}


sub generate_currency_curves() 
{

    my $file = "$dummy_data_root/currency_curves.sql";
    open FILE, ">$file" or die "Can't open $file";

    print FILE "delete from currency_curves;\n";

    my $id = get_next_id();
    my $name = "USD-CCY-CURVES";
    my $interest_rate = 1;

    print FILE "insert into object values (  $id, 2, \"$name\" );\n";
    print FILE "insert into currency_curves values ( $id, $interest_rate );\n";

    push @currency_curve_ids, $id;

    $id = get_next_id();
    $interest_rate = 2;

    print FILE "insert into object values (  $id, 2, \"$name\" );\n";
    print FILE "insert into currency_curves values ( $id, $interest_rate );\n";

    push @currency_curve_ids, $id;

    $id = get_next_id();
    $interest_rate = 3;

    print FILE "insert into object values (  $id, 2, \"$name\" );\n";
    print FILE "insert into currency_curves values ( $id, $interest_rate );\n";

    push @currency_curve_ids, $id;

    close FILE;
}

sub generate_books() {

    my $FILE;
    my $id;

    $id = get_next_id();
    $FILE = open_file( $id, 7 );
    print $FILE "OUTBK_1,5,1,0,0,0\n";
    close $FILE;
    push @outright_agg, 1;

    $id = get_next_id();
    $FILE = open_file( $id, 7 );
    print $FILE "OUTBK_2,5,2,0,0,0\n";
    close $FILE;
    push @outright_agg, 2;

    $id = get_next_id();
    $FILE = open_file( $id, 7 );
    print $FILE "OUTBK_3,5,3,0,0,0\n";
    close $FILE;
    push @outright_agg, 3;

    $id = get_next_id();
    $FILE = open_file( $id, 7 );
    print $FILE "OUTBK_4,5,4,0,0,0\n";
    close $FILE;
    push @outright_agg, 4;


    $id = get_next_id();
    $FILE = open_file( $id, 8 );
    print $FILE "REOPBK_1,5,1,0,0,0\n";
    close $FILE;
    push @repo_agg, 1;

    $id = get_next_id();
    $FILE = open_file( $id, 8 );
    print $FILE "REOPBK_2,5,2,0,0,0\n";
    close $FILE;
    push @repo_agg, 2;

    $id = get_next_id();
    $FILE = open_file( $id, 8 );
    print $FILE "REOPBK_3,5,3,0,0,0\n";
    close $FILE;
    push @repo_agg, 3;

    $id = get_next_id();
    $FILE = open_file( $id, 8 );
    print $FILE "REOPBK_4,5,4,0,0,0\n";
    close $FILE;
    push @repo_agg, 4;

}  

sub generate_fx_rates() {

    my $FILE;

    my $id = 4;
    $FILE = open_file( $id, 6 );
    print $FILE "USD-GBP,5,1,2,0.509242756,\n";
    close $FILE;
    $fx_rates{12} = $id;

    $id = 5;
    $FILE = open_file( $id, 6 );
    print $FILE "GBP-EUR,5,2,3,1.4734749,\n";
    close $FILE;
    $fx_rates{23} = $id;

    $id = 6;
    $FILE = open_file( $id, 6 );
    print $FILE "EUR-USD,5,3,1,1.3327,\n";
    close $FILE;
    $fx_rates{31} = $id;

    $id = 7;
    $FILE = open_file( $id, 6 );
    print $FILE "GBP-USD,5,2,1,".(1.0/0.509242756).",\n";
    close $FILE;
    $fx_rates{21} = $id;

    $id = 8;
    $FILE = open_file( $id, 6 );
    print $FILE "EUR-GBP,5,3,2,".(1.0/1.4734749).",\n";
    close $FILE;
    $fx_rates{32} = $id;

    $id = 10;
    $FILE = open_file( $id, 6 );
    print $FILE "USD-EUR,5,1,3,".(1.0/1.3327).",\n";
    close $FILE;
    $fx_rates{13} = $id;

    $id = 11;
    $FILE = open_file( $id, 6 );
    print $FILE "USD-USD,5,1,1,1.0,\n";
    close $FILE;
    $fx_rates{11} = $id;

    $id = 12;
    $FILE = open_file( $id, 6 );
    print $FILE "GBP-GBP,5,2,2,1.0,\n";
    close $FILE;
    $fx_rates{22} = $id;

    $id = 13;
    $FILE = open_file( $id, 6 );
    print $FILE "EUR-EUR,5,3,3,1.0,\n";
    close $FILE;
    $fx_rates{33} = $id;

}

sub generate_bonds($) {
    my $num_bonds = shift;

    my $file = "$dummy_data_root/bonds.sql";
    open FILE, ">$file" or die "Can't open $file";

    print FILE "delete from bond;\n";

    my ( $id, $name, $currency_curve );

    for ( my $i = 0 ; $i < $num_bonds ; $i++ ) {

        $id = get_next_id();
        $name = $chars[ int(rand( @chars )) ].$chars[ int(rand( @chars )) ].int( rand(999999999));

        $currency_curve = $currency_curve_ids[ int( rand( @currency_curve_ids )) ];

        print FILE "insert into object values (  $id, 3, \"$name\" );\n";

        print FILE "insert into bond values (  $id, ".
            sprintf("%.2f", (rand( 8 - 2 ) + 2)).",".
            int( 6000 + rand(  8000 - 6000 )).",".
            int( 18000 + rand( 20000 - 18000 )).",".
            $coup_pys[ int( rand( @coup_pys )) ].",".
            $currency_curve.");\n;";
            
        push @bond_ids, $id;
        $bond_to_ccy_curve{$id} = $currency_curve;
    }
    close FILE;

}
                 
sub generate_outright_trades($) {
    my $num_outrignt_trades = shift;

    my $file = "$dummy_data_root/outright_trades.sql";
    open FILE, ">$file" or die "Can't open $file";

    print FILE "delete from outright_trade;\n";

    my ( $id, $name, $currency_curve );

    for ( my $i = 0 ; $i < $num_outrignt_trades ; $i++ ) {

        $id = get_next_id();

        $name = "C".int( rand(999999));

        print FILE "insert into object values (  $id, 4, \"$name\" );\n";

        print FILE "insert into outright_trade values ( $id, ".
            1000 * int( rand( 1000  )).",".
            int( 8000 + rand(  99999 - 8000 )).",".
            sprintf("%.2f", 95.0 + (rand( 10 ))).",".
            "0,".
            $bond_ids[ int( rand( @bond_ids )) ].");\n";

    }

    close FILE;

}

sub generate_repo_trades($) {
    my $num_objects = shift;

    my $file = "$dummy_data_root/repo_trades.sql";
    open FILE, ">$file" or die "Can't open $file";

    print FILE "delete from repo_trade;\n";

    my ( $id, $name, $currency_curve );

    for ( my $i = 0 ; $i < $num_objects ; $i++ ) {

        $id = get_next_id();

        my $name = "R".int( rand(999999));

        print FILE "insert into object values (  $id, 5, \"$name\" );\n";

        my $cash_ccy = $currencies[ int( rand( @currencies )) ];
        my $notional = 10000 * int( rand( 100  ));
        my $bond = $bond_ids[ int( rand( @bond_ids )) ];
        my $bond_ccy = $bond_ccys{$bond};
        my $interest_rate = $bond_to_ccy_curve{$bond};

        print FILE "insert into repo_trade values ( $id, ". 
            int( 8000 + rand(  99999 - 8000 )).",".
            int( 16000 + rand(  18000 - 16000 )).",".
            "$notional,$cash_ccy,".
            sprintf("%.2f", (rand( 8 - 2 ) + 2)).",".
            $notional * int( sprintf("%.2f", 95.0 + (rand( 10 )))).",".
            "0,".
            $bond.",".
            $interest_rate.");\n";

    }

    close FILE;
}

sub get_next_id() {

    return $current_id++;

}

sub open_file($$) {
    my $id = shift;
    my $type = shift;

    my $file = "$dummy_data_root/$id.$type.t4o";

    open FILE, ">$file" or die "Can't open $file";
    
    return *FILE;

}
