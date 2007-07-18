#!/usr/bin/perl

use warnings;
use strict;

sub get_next_id();
sub open_file($$);

sub generate_risk_free_rate_feeds();
sub generate_stock_feeds();
sub generate_options($);
sub generate_option_managers();


my $current_id = 20;
my $dummy_data_root="$ENV{INSTANCE_ROOT}/data/stress_test";
my @currencies = ( "null", "USD", "GBP", "EUR" );

my @stock_ids;
my %stock_prices;
my %stock_names;
my @option_ids;
my %option_stock_ids;
my %option_rfr_ids;

generate_risk_free_rate_feeds();
generate_stock_feeds();
generate_options( 1000 );
generate_option_managers();

sub generate_option_managers() {

    my ( $id, $FILE, $rfr, $stock, $name, $ccy, $option );

    foreach $ccy ( 1, 2, 3 ) {

        foreach $stock ( @stock_ids ) {

            $name = "OPTVEC_".$currencies[$ccy]."_".$stock_names{$stock};

            $id = get_next_id();
            $FILE = open_file( $id, 4 );
            
            print $FILE "$name,5,$stock,$ccy,3\n";
            close $FILE;
            
            open FILE_T4V, ">$dummy_data_root/$id.4.t4v" or die "Can't open $dummy_data_root/$id.4.t4v";

            foreach $option ( @option_ids ) {

                if ( $option_stock_ids{$option} eq $stock && $option_rfr_ids{$option} eq $ccy ) {

                    print FILE_T4V "$option\n";

                }

            }

            close FILE_T4V;

        }
    }

}

sub generate_options($) {
    my $num_options = shift;

    my ( $id, $FILE, $name, $stock_id, $stock_price, $risk_free_rate, $time_to_maturity, $strike_price, $mult, $call_or_put  );

    while ( $num_options > 0 ) {

        $id = get_next_id();
        $FILE = open_file( $id, 3 );
       
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

        print $FILE "$name,5,$stock_id,$risk_free_rate,$time_to_maturity,$strike_price,$call_or_put,0,0,0,0,0,0\n";

        push @option_ids, $id;
        $option_stock_ids{$id} = $stock_id;
        $option_rfr_ids{$id} = $risk_free_rate;
    
        close $FILE; 
        $num_options--;
    }

}

sub generate_stock_feeds()
{

    open IN_FILE, "$ENV{INSTANCE_ROOT}/spreadsheets/FTSE250_Data.csv" or die "Can't open $ENV{INSTANCE_ROOT}/spreadsheets/FTSE250_Data.csv";

    my ( $line, $id);
    my @line_array;
    my $FILE;

    while ( $line = <IN_FILE> ) {

        chomp( $line );

        @line_array = split /,/, $line;
        
        $id = get_next_id();
        $FILE = open_file( $id, 2 );
        print $FILE "$line_array[0],5,$line_array[2],$line_array[3],$line_array[3]*$line_array[3]\n";
        close $FILE; 

        push @stock_ids, $id;

        $stock_prices{$id} = $line_array[2];
        $stock_names{$id} = $line_array[0];

    }



}

sub generate_risk_free_rate_feeds() {

    my $FILE;

    $FILE = open_file( 1, 1 );
    print $FILE "RFR-USD,5,5.376\n";
    close $FILE;

    $FILE = open_file( 2, 1 );
    print $FILE "RFR-GBP,5,5.244\n";
    close $FILE;

    $FILE = open_file( 3, 1 );
    print $FILE "RFR-EUR,5,3.58\n";
    close $FILE;

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
                                                                              

