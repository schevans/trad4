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


my @discount_rate_ids;
my @interest_rate_ids;


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
#generate_discount_rates();
#generate_fx_rates();
#generate_bonds( 400 );
#generate_outright_trades( 2000 );
#generate_repo_trades( 2000 );

sub generate_interest_rates() {

    my $id = 1;
    my $file = "$dummy_data_root/$id.1.t4o";
    my $data_file = "$dummy_data_root/$id.1.t4d";

    open FILE, ">$file" or die "Can't open $file";
    print FILE "LIBOR-USD,5,1,\n";
    close FILE;

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
    $file = "$dummy_data_root/$id.1.t4o";
    $data_file = "$dummy_data_root/$id.1.t4d";

    open FILE, ">$file" or die "Can't open $file";
    print FILE "LIBOR-GBP,5,1,\n";
    close FILE;

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
    $file = "$dummy_data_root/$id.1.t4o";
    $data_file = "$dummy_data_root/$id.1.t4d";

    open FILE, ">$file" or die "Can't open $file";
    print FILE "LIBOR-EUR,5,1,\n";
    close FILE;

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

    open FILE, ">$discount_rate_file" or die "Can't open $discount_rate_file";

    print FILE "delete from discount_rate;\n";
    
    my $id = get_next_id();
    my $name = "DISCO-USD";
    my $ccy = 1;
    print FILE "insert into object select $id, number, \"$name\", 5, 1 from object_type where name = \"discount_rate\"\;\n";
    print FILE "insert into discount_rate values ( $id, $ccy, $interest_rate_ids[$ccy-1] );\n";

    push @discount_rate_ids, $id;

    $id = get_next_id();
    $name = "DISCO-GBP";
    $ccy = 2;
    print FILE "insert into object select $id, number, \"$name\", 5, 1 from object_type where name = \"discount_rate\"\;\n";
    print FILE "insert into discount_rate values ( $id, $ccy, $interest_rate_ids[$ccy-1] );\n";

    push @discount_rate_ids, $id;

    $id = get_next_id();
    $name = "DISCO-EUR";
    $ccy = 3;
    print FILE "insert into object select $id, number, \"$name\", 5, 1 from object_type where name = \"discount_rate\"\;\n";
    print FILE "insert into discount_rate values ( $id, $ccy, ".$interest_rate_ids[$ccy-1]." );\n";

    push @discount_rate_ids, $id;

    close FILE;
}


sub generate_fx_rates() {

    open FILE, ">$fx_rate_file" or die "Can't open $fx_rate_file";

    print FILE "delete from fx_rate;\n";
    
    my $id = 4;
    my $name = "USD-GBP";
    print FILE "insert into object select $id, number, \"$name\", 5, 1 from object_type where name = \"fx_rate\"\;\n";
    print FILE "insert into fx_rate values ( $id, 1, 2, 0, 0.509242756 )\;\n";

    $id = 5;
    $name = "GBP-EUR";
    print FILE "insert into object select $id, number, \"$name\", 5, 1 from object_type where name = \"fx_rate\"\;\n";
    print FILE "insert into fx_rate values ( $id, 2, 3, 0, 1.4734749 )\;\n";

    $id = 6;
    $name = "EUR-USD";
    print FILE "insert into object select $id, number, \"$name\", 5, 1 from object_type where name = \"fx_rate\"\;\n";
    print FILE "insert into fx_rate values ( $id, 3, 1, 0, 1.3327 )\;\n";

    $id = 7;
    $name = "GBP-USD";
    print FILE "insert into object select $id, number, \"$name\", 5, 1 from object_type where name = \"fx_rate\"\;\n";
    print FILE "insert into fx_rate values ( $id, 2, 1, 0, 1.0/0.509242756 )\;\n";

    $id = 8;
    $name = "EUR-GBP";
    print FILE "insert into object select $id, number, \"$name\", 5, 1 from object_type where name = \"fx_rate\"\;\n";
    print FILE "insert into fx_rate values ( $id, 3, 2, 0, 1.0/1.4734749 )\;\n";

    $id = 10;
    $name = "USD-EUR";
    print FILE "insert into object select $id, number, \"$name\", 5, 1 from object_type where name = \"fx_rate\"\;\n";
    print FILE "insert into fx_rate values ( $id, 1, 3, 0, 1.0/1.3327 )\;\n";

    $id = 11;
    $name = "USD-USD";
    print FILE "insert into object select $id, number, \"$name\", 5, 1 from object_type where name = \"fx_rate\"\;\n";
    print FILE "insert into fx_rate values ( $id, 1, 1, 0, 1.0 )\;\n";

    $id = 12;
    $name = "GBP-GBP";
    print FILE "insert into object select $id, number, \"$name\", 5, 1 from object_type where name = \"fx_rate\"\;\n";
    print FILE "insert into fx_rate values ( $id, 2, 2, 0, 1.0 )\;\n";

    $id = 13;
    $name = "EUR-EUR";
    print FILE "insert into object select $id, number, \"$name\", 5, 1 from object_type where name = \"fx_rate\"\;\n";
    print FILE "insert into fx_rate values ( $id, 3, 3, 0, 1.0 )\;\n";

    close FILE;
}

sub generate_bonds($) {
    my $num_bonds = shift;


    open FILE, ">/home/steve/src/trad4/instance/trad_bond_risk/gen/dummy_data/dummy_bonds.sql" or die "Can't open /home/steve/src/trad4/instance/trad_bond_risk/gen/dummy_data/dummy_bonds.sql";

    print FILE "delete from bond;\n";

    for ( my $i = 0 ; $i < $num_bonds ; $i++ ) {

        my $id = get_next_id();

        my $name = $chars[ int(rand( @chars )) ].$chars[ int(rand( @chars )) ].int( rand(999999999));

        print FILE "insert into object select $id, number, \"$name\", 5, 1 from object_type where name = \"bond\"\;\n";
                                
        print FILE "insert into bond values ( $id, ".
                                sprintf("%.2f", (rand( 8 - 2 ) + 2)).", ".
                                int( 6000 + rand(  8000 - 6000 )).", ".
                                int( 18000 + rand( 20000 - 18000 )).", ".
                                $coup_pys[ int( rand( @coup_pys )) ].", ".
                                $currencies[ int( rand( @currencies )) ].", ".
                                $discount_rate_ids[ int( rand( @discount_rate_ids )) ].", ".
                                "null )\;\n";

        push @bond_ids, $id;
    }

    close FILE;
}
                 
sub generate_outright_trades($) {
    my $num_objects = shift;

    open FILE, ">$outright_trades_file" or die "Can't open $outright_trades_file";

    print FILE "delete from outright_trade;\n";

    for ( my $i = 0 ; $i < $num_objects ; $i++ ) {

        my $id = get_next_id();

        my $name = "C".int( rand(999999));

        print FILE "insert into object select $id, number, \"$name\", 5, 1 from object_type where name = \"outright_trade\"\;\n";

        print FILE "insert into outright_trade values ( $id, ".
                                1000 * int( rand( 1000  )).", ".
                                int( 8000 + rand(  99999 - 8000 )).", ".
                                sprintf("%.2f", 95.0 + (rand( 10 ))).", ".
                                $bond_ids[ int( rand( @bond_ids )) ].", ".
                                "null, ".
                                "null, ".
                                "null )\;\n";

    }

    close FILE;



}

sub generate_repo_trades($) {
    my $num_objects = shift;

    open FILE, ">$repo_trades_file" or die "Can't open $repo_trades_file";

    print FILE "delete from repo_trade;\n";

    for ( my $i = 0 ; $i < $num_objects ; $i++ ) {

        my $id = get_next_id();

        my $name = "R".int( rand(999999));

        print FILE "insert into object select $id, number, \"$name\", 5, 1 from object_type where name = \"repo_trade\"\;\n";

        my $cash_ccy = $currencies[ int( rand( @currencies )) ];
        my $notional = 10000 * int( rand( 100  ));
        my $bond = $bond_ids[ int( rand( @bond_ids )) ];

        print FILE "insert into repo_trade select $id, ".
                                int( 8000 + rand(  99999 - 8000 )).", ".
                                int( 16000 + rand(  18000 - 16000 )).", ".
                                $notional.", ".
                                $cash_ccy.", ".
                                sprintf("%.2f", (rand( 8 - 2 ) + 2)).", ".
                                $notional * int( sprintf("%.2f", 95.0 + (rand( 10 )))).", ".
        
                                "fx.id, ".

                                "$bond, ".
                                "null, ".
                                "null ".

                                
                                " from bond b, fx_rate fx where fx.ccy1 = $cash_ccy and b.id = $bond and b.ccy = fx.ccy2\;\n";

    }

    close FILE;

}

sub get_next_id() {

    return $current_id++;

}


