#!/usr/bin/perl

use warnings;
use strict;

sub get_next_id();
sub generate_interest_rates();
sub generate_discount_rates();
sub generate_fx_rates();
sub generate_bonds($);
sub generate_outright_trades($);
sub generate_repo_trades($);
sub generate_object($$);

my $current_id = 20;


my %discount_rate_ids;
my @interest_rate_ids;
my %bond_ccys;
my %fx_rates;


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

generate_interest_rates();
generate_discount_rates();
generate_fx_rates();
generate_bonds( 3000 );
generate_outright_trades( 6000 );
generate_repo_trades( 6000 );

sub generate_interest_rates() {

    my $id = 1;
    my $FILE = open_file( $id, 1 ); 
    print FILE "LIBOR-USD,5,1,\n";
    close $FILE;

    my $data_file = "$dummy_data_root/$id.1.t4d";
    open FILE, ">$data_file" or die "Can't open $data_file";

    print FILE "10000,2.6\n";
    print FILE "10010,2.7\n";
    print FILE "10100,2.7\n";
    print FILE "10200,2.7\n";
    print FILE "10300,2.8\n";
    print FILE "12000,2.8\n";
    print FILE "13000,2.9\n";
    print FILE "15000,2.9\n";
    print FILE "18000,2.8\n";
    print FILE "20000,2.8\n";
    close FILE;

    push @interest_rate_ids, $id;

    $id = 2;
    $FILE = open_file( $id, 1 ); 
    print $FILE "LIBOR-GBP,5,1,\n";
    close $FILE;

    $data_file = "$dummy_data_root/$id.1.t4d";
    open FILE, ">$data_file" or die "Can't open $data_file";

    print FILE "10000,5.2\n";
    print FILE "10010,5.3\n";
    print FILE "10100,5.4\n";
    print FILE "10200,5.4\n";
    print FILE "10300,5.5\n";
    print FILE "12000,5.5\n";
    print FILE "13000,5.5\n";
    print FILE "15000,5.4\n";
    print FILE "18000,5.3\n";
    print FILE "20000,5.3\n";
    close FILE;

    push @interest_rate_ids, $id;

    $id = 3;
    $FILE = open_file( $id, 1 ); 
    print $FILE "LIBOR-EUR,5,1,\n";
    close $FILE;

    $data_file = "$dummy_data_root/$id.1.t4d";
    open FILE, ">$data_file" or die "Can't open $data_file";

    print FILE "10000,3.6\n";
    print FILE "10010,3.7\n";
    print FILE "10100,3.7\n";
    print FILE "10200,3.7\n";
    print FILE "10300,3.8\n";
    print FILE "12000,3.8\n";
    print FILE "13000,3.9\n";
    print FILE "15000,3.9\n";
    print FILE "18000,3.8\n";
    print FILE "20000,3.8\n";
    close FILE;

    push @interest_rate_ids, $id;

    close FILE;
}


sub generate_discount_rates() {

    my $FILE;

    my $id = get_next_id();
    my $name = "DISCO-USD";
    my $ccy = 1;

    $FILE = open_file( $id, 2 );
    print $FILE "DISCO-USD,5,$interest_rate_ids[$ccy-1],$ccy,";
    close $FILE;

    $discount_rate_ids{$ccy} = $id;

    $id = get_next_id();
    $ccy = 2;
    $FILE = open_file( $id, 2 );
    print $FILE "DISCO-GBP,5,$interest_rate_ids[$ccy-1],$ccy,";
    close $FILE;

    $discount_rate_ids{$ccy} = $id;

    $id = get_next_id();
    $ccy = 3;
    $FILE = open_file( $id, 2 );
    print $FILE "DISCO-EUR,5,$interest_rate_ids[$ccy-1],$ccy,";
    close $FILE;

    $discount_rate_ids{$ccy} = $id;

    close FILE;
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

    my $FILE;
    my ( $id, $name, $ccy );

    for ( my $i = 0 ; $i < $num_bonds ; $i++ ) {

        $id = get_next_id();

        $name = $chars[ int(rand( @chars )) ].$chars[ int(rand( @chars )) ].int( rand(999999999));

        $ccy = $currencies[ int( rand( @currencies )) ];

        $FILE = open_file( $id, 3 );
        print $FILE "$name,5,".
            $discount_rate_ids{$ccy}.",".
            sprintf("%.2f", (rand( 8 - 2 ) + 2)).",".
            int( 6000 + rand(  8000 - 6000 )).",".
            int( 18000 + rand( 20000 - 18000 )).",".
            $coup_pys[ int( rand( @coup_pys )) ].",".
            $ccy.",".
            "0,\n";

        push @bond_ids, $id;
        $bond_ccys{$id} = $ccy;

        close $FILE;
    }

}
                 
sub generate_outright_trades($) {
    my $num_objects = shift;

    my ( $FILE, $id, $name );

    for ( my $i = 0 ; $i < $num_objects ; $i++ ) {

        $id = get_next_id();

        $name = "C".int( rand(999999));

        $FILE = open_file( $id, 4 );

        print $FILE "$name,5,".
            $bond_ids[ int( rand( @bond_ids )) ].",".
            1000 * int( rand( 1000  )).",".
            int( 8000 + rand(  99999 - 8000 )).",".
            sprintf("%.2f", 95.0 + (rand( 10 ))).",".
            "0,0,0,\n";

        close $FILE;
    }


}

sub generate_repo_trades($) {
    my $num_objects = shift;

    for ( my $i = 0 ; $i < $num_objects ; $i++ ) {

        my $id = get_next_id();

        my $name = "R".int( rand(999999));

        my $cash_ccy = $currencies[ int( rand( @currencies )) ];
        my $notional = 10000 * int( rand( 100  ));
        my $bond = $bond_ids[ int( rand( @bond_ids )) ];
        my $bond_ccy = $bond_ccys{$bond};
        my $fx_rate_key = "$bond_ccy$cash_ccy";
        my $fx_rate_id = $fx_rates{$fx_rate_key};

        my $FILE = open_file( $id, 5 );
    
        print $FILE "$name,5,$fx_rate_id,$bond,".
            int( 8000 + rand(  99999 - 8000 )).",".
            int( 16000 + rand(  18000 - 16000 )).",".
            "$notional,$cash_ccy,".
            sprintf("%.2f", (rand( 8 - 2 ) + 2)).",".
            $notional * int( sprintf("%.2f", 95.0 + (rand( 10 )))).",".
            "0,0,0,\n";

        close $FILE;
    }


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
