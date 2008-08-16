#!/usr/bin/perl

# Copyright (c) Steve Evans 2007
# steve@topaz.myzen.co.uk
# This code is licenced under the BSD licence. For details see $APP_ROOT/LICENCE

use warnings;

sub get_next_id();
sub open_file($);

sub generate_risk_free_rates();
sub generate_stocks();
sub generate_options($);
sub generate_rate_trades();
sub generate_stock_trades();
sub generate_bs_delta();
sub generate_vega();
sub generate_theta();
sub generate_price();
sub generate_rho();
sub generate_gamma();


my $current_id = 20;
my $dummy_data_root="$ENV{APP_ROOT}/data/dummy_data";
my @currencies = ( "null", "USD", "GBP", "EUR" );

my @stock_ids;
my %stock_prices;
my %stock_names;
my @option_ids;
my %option_stock_ids;
my %option_rfr_ids;
my %option_name;
my %option_stock_trade;
my %option_rate_trade;
my %option_bs_delta;
my %option_rho;

generate_risk_free_rates();
generate_stocks();
generate_options( 110000 );
generate_rate_trades();
generate_stock_trades();
generate_bs_delta();
generate_vega();
generate_theta();
#generate_price();
generate_rho();
generate_gamma();
generate_price();

sub generate_price() {

    my $FILE = open_file( "price" );

    print $FILE "delete from price;\n";

    my ( $option, $id );

    foreach $option ( @option_ids ) {

        $id = get_next_id();

        print $FILE "insert into object values ( $id, 11, \"$option_name{$option}_price\", 0, 0 );\n";

        print $FILE "insert into price values ( $id, $option_bs_delta{$option}, $option_stock_ids{$option}, $option, $option_rate_trade{$option} );\n";


    }

    close $FILE;
}


sub generate_gamma() {

    my $FILE = open_file( "gamma" );

    print $FILE "delete from gamma;\n";

    my ( $option, $id );

    foreach $option ( @option_ids ) {

        $id = get_next_id();

        print $FILE "insert into object values ( $id, 10, \"$option_name{$option}_gamma\", 0, 0 );\n";

        print $FILE "insert into gamma values ( $id, $option_bs_delta{$option}, $option_stock_trade{$option}, $option_stock_ids{$option} );\n";


    }

    close $FILE;
}

sub generate_rho() {

    my $FILE = open_file( "rho" );

    print $FILE "delete from rho;\n";

    my ( $option, $id );

    foreach $option ( @option_ids ) {

        $id = get_next_id();

        print $FILE "insert into object values ( $id, 8, \"$option_name{$option}_rho\", 0, 0 );\n";

        print $FILE "insert into rho values ( $id, $option, $option_rate_trade{$option}, $option_bs_delta{$option} );\n";

        $option_rho{$option} = $id;

    }

    close $FILE;
}



sub generate_theta() {

    my $FILE = open_file( "theta" );

    print $FILE "delete from theta;\n";

    my ( $option, $id );

    foreach $option ( @option_ids ) {

        $id = get_next_id();

        print $FILE "insert into object values ( $id, 7, \"$option_name{$option}_theta\", 0, 0 );\n";

        print $FILE "insert into theta values ( $id, $option, $option_stock_ids{$option}, $option_rate_trade{$option}, $option_bs_delta{$option} );\n";


    }


    close $FILE;

}

sub generate_vega() {

    my $FILE = open_file( "vega" );

    print $FILE "delete from vega;\n";

    my ( $option, $id );

    foreach $option ( @option_ids ) {

        $id = get_next_id();

        print $FILE "insert into object values ( $id, 9, \"$option_name{$option}_vega\", 0, 0 );\n";

        print $FILE "insert into vega values ( $id, $option_bs_delta{$option}, $option_stock_ids{$option}, $option );\n";


    }


    close $FILE;

}


sub generate_bs_delta() {

    my $FILE = open_file( "bs_delta" );

    print $FILE "delete from bs_delta;\n";

    my ( $option, $id );

    foreach $option ( @option_ids ) {

        $id = get_next_id();

        print $FILE "insert into object values ( $id, 6, \"$option_name{$option}_BS\", 0, 0 );\n";

        print $FILE "insert into bs_delta values ( $id, $option_rate_trade{$option}, $option_stock_trade{$option}, $option );\n";

        $option_bs_delta{$option} = $id;

    }


    close $FILE;


}

sub generate_stock_trades() {

    my $FILE = open_file( "stock_trade" );

    print $FILE "delete from stock_trade;\n";

    my ( $option, $id );

    foreach $option ( @option_ids ) {

        $id = get_next_id();

        print $FILE "insert into object values ( $id, 4, \"$option_name{$option}_ST\", 0, 0 );\n";

        print $FILE "insert into stock_trade values ( $id, $option, $option_stock_ids{$option} );\n";

        $option_stock_trade{$option} = $id;

    }


    close $FILE;
}


sub generate_rate_trades() {

    my $FILE = open_file( "rate_trade" );

    print $FILE "delete from rate_trade;\n";

    my ( $option, $id );

    foreach $option ( @option_ids ) {

        $id = get_next_id();

        print $FILE "insert into object values ( $id, 5, \"$option_name{$option}_RT\", 0, 0 );\n";

        print $FILE "insert into rate_trade values ( $id, $option, $option_rfr_ids{$option} );\n";

        $option_rate_trade{$option} = $id;
    }


    close $FILE;
}

sub generate_options($) {
    my $num_options = shift;

    my ( $id, $FILE, $risk_free_rate, $stock_id, $name, $time_to_maturity, $stock_price, $strike_price, $mult, $call_or_put  );

    $FILE = open_file( "option" );

    print $FILE "delete from option;\n";


    while ( $num_options > 0 ) {

        $id = get_next_id();
       
        $name = "O".int( rand(99999));
 
        $stock_id = $stock_ids[ rand ( @stock_ids ) ];
        $stock_price = $stock_prices{ $stock_id };
        $risk_free_rate = int( rand( 3 )) + 1;  

        $time_to_maturity = 0.5 + int ( rand ( 10 ) ) / 4;

        if ( int ( rand ( 2 )) )
        {
            $mult = 1;
        }
        else {
            $mult = -1;
        }

        $call_or_put = int ( rand ( 2 ));

        $strike_price = $stock_price + ( int ( rand ( $stock_price / 20 )) * $mult );

        print $FILE "insert into object values ( $id, 1, \"$name\", 0, 0 );\n";

        print $FILE "insert into option values ( $id, $time_to_maturity, $strike_price, $call_or_put );\n";
        $option_name{$id} = $name;
        push @option_ids, $id;
        $option_stock_ids{$id} = $stock_id;
        $option_rfr_ids{$id} = $risk_free_rate;
    
        $num_options--;
    }
    close $FILE; 

}

sub generate_stocks()
{

    open IN_FILE, "$ENV{APP_ROOT}/spreadsheets/FTSE250_Data.csv" or die "Can't open $ENV{APP_ROOT}/spreadsheets/FTSE250_Data.csv";

    my ( $line, $id);
    my @line_array;
    my $FILE;

    $FILE = open_file( "stock" );

    print $FILE "delete from stock;\n";

    while ( $line = <IN_FILE> ) {

        chomp( $line );

        @line_array = split /,/, $line;
        
        $id = get_next_id();

        print $FILE "insert into object values ( $id, 3, \"$line_array[0]\", 0, 1 );\n";
        print $FILE "insert into stock values ( $id, $line_array[2], $line_array[3] );\n";

        push @stock_ids, $id;

        $stock_prices{$id} = $line_array[2];
        $stock_names{$id} = $line_array[0];

    }

}

sub generate_risk_free_rates() {

    my $FILE;

    $FILE = open_file( "risk_free_rate" );

    print $FILE "delete from risk_free_rate;\n";

    print $FILE "insert into object values ( 1, 2, \"RFR-USD\", 0, 1 );\n";
    print $FILE "insert into risk_free_rate values ( 1, 0.035 );\n";

    print $FILE "insert into object values ( 2, 2, \"RFR-GBP\", 0, 1 );\n";
    print $FILE "insert into risk_free_rate values ( 2, 0.045 );\n";

    print $FILE "insert into object values ( 3, 2, \"RFR-EUR\", 0, 1 );\n";
    print $FILE "insert into risk_free_rate values ( 3, 0.0475 );\n";

    close $FILE;

}

sub get_next_id() {

    return $current_id++;

}

sub open_file($) {
    my $name = shift;

    my $file = "$dummy_data_root/$name.sql";

    open FILE, ">$file" or die "Can't open $file";

    return *FILE;

}
                                                                              

