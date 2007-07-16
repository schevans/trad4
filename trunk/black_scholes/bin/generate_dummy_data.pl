#!/usr/bin/perl

use warnings;
use strict;

sub get_next_id();
sub open_file($$);

sub generate_risk_free_rate_feeds();
sub generate_stock_feeds();


my $current_id = 20;
my $dummy_data_root="$ENV{DATA_DIR}";

my @stock_ids;

generate_risk_free_rate_feeds();
generate_stock_feeds();


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
    print $FILE "RFR-USD,5,3.58\n";
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
                                                                              

