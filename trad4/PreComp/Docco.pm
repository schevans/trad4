# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk
#

package PreComp::Docco;

use Data::Dumper;
use warnings;

sub Generate($) {
    my $master_hash = shift;

    my $app_name = $ENV{APP};

    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::DoccoRoot()."$app_name.html");

    print $FHD "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n";
    print $FHD "  <!DOCTYPE html\n";
    print $FHD "            PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"\n";
    print $FHD "            \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n";
    print $FHD "\n";
    print $FHD "     <html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">\n";
    print $FHD "\n";
    print $FHD "<head>\n";
    print $FHD "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\" />\n";
    print $FHD "<link rel=\"stylesheet\" type=\"text/css\" href=\"http://trad4.sourceforge.net/gcc.css\" />\n";
    print $FHD "<title>\n";
    print $FHD "$app_name - a trad4 application\n";
    print $FHD "</title>\n";
    print $FHD "</head>\n";
    print $FHD "\n";
    print $FHD "<body bgcolor=\"#FFFFFF\" text=\"#000000\" link=\"#1F00FF\" alink=\"#FF0000\" vlink=\"#9900DD\">\n";
    print $FHD "\n";
    print $FHD "<h1 align=\"center\">\n";
    print $FHD "$app_name\n";
    print $FHD "</h1>\n";
    print $FHD "\n";
    print $FHD "<table border=\"1\">\n";
    print $FHD "<tr>\n";
    print $FHD "<td>Download version</td>\n";
    print $FHD "<td></td>\n";
    print $FHD "</tr>\n";
    print $FHD "<tr>\n";
    print $FHD "<td>Download licence</td>\n";
    print $FHD "<td></td>\n";
    print $FHD "</tr>\n";
    print $FHD "<tr>\n";
    print $FHD "<td>Trad4 version</td>\n";
    print $FHD "<td></td>\n";
    print $FHD "</tr>\n";
    print $FHD "<tr>\n";
    print $FHD "<td>Author</td>\n";
    print $FHD "<td></td>\n";
    print $FHD "</tr>\n";
    print $FHD "<tr>\n";
    print $FHD "<td>Date</td>\n";
    print $FHD "<td></td>\n";
    print $FHD "</tr>\n";
    print $FHD "</table>\n";
    print $FHD "\n";
    print $FHD "<ul>\n";
    print $FHD "<li><a href=\"#introduction\">Introduction</a></li>\n";
    print $FHD "<li><a href=\"#the_model\">The Model</a></li>\n";
    print $FHD "<li><a href=\"#implementation\">Implementation</a></li>\n";
    print $FHD "</ul>\n";
    print $FHD "\n";
    print $FHD "<hr />\n";
    print $FHD "\n";
    print $FHD "<h2><a name=\"introduction\">Introduction</a></h2>\n";
    print $FHD "<p>\n";
    print $FHD "\n";
    print $FHD "</p>\n";
    print $FHD "<h2><a name=\"the_model\">The Model</a></h2>\n";
    print $FHD "<p>\n";
    print $FHD "\n";
    print $FHD "</p>\n";
    print $FHD "<h2><a name=\"implementation\">Implementation</a></h2>\n";
    print $FHD "<p>\n";
    print $FHD "\n";
    print $FHD "</p>\n";
    print $FHD "<h3>The t4 files</h3>\n";

    my %simple_hash;

    foreach $type ( keys %{$master_hash} ) {

        $simple_hash{$type} = $master_hash->{$type}->{type_num};
    }

    foreach $type ( sort{ $simple_hash{$a} <=> $simple_hash{$b} } keys %simple_hash ) {

        print $FHD "<p>\n";
        print $FHD "<h4>$type.t4:</h4>\n";
        print $FHD "</p>\n";
        print $FHD "<blockquote><pre>\n";

        if ( $master_hash->{$type}->{data}->{implements} eq $type ) {

            foreach $section ( "sub", "static", "pub" ) {

                PrintT4Section( $master_hash, $section, $type, $FHD );

            }
        }
        else {

            print $FHD "implements $master_hash->{$type}->{data}->{implements}\n";
        }

        print $FHD "</pre></blockquote>\n";

        print $FHD "<p>\n";
        print $FHD "\n";
        print $FHD "</p>\n";
    }

    print $FHD "\n";
    print $FHD "\n";
    print $FHD "\n";
    print $FHD "</body>\n";
    print $FHD "</html>\n";

    PreComp::Utilities::CloseFile();

}

sub PrintT4Section($$$$) {
    my $master_hash = shift;
    my $section_type = shift;
    my $type = shift;
    my $FHD = shift;

    my $section = $section_type;
    my $section_vec = $section_type."_vec";
    my $section_order = $section_type."_order";
    my $section_vec_order = $section_type."_vec_order";

    if ( exists $master_hash->{$type}->{data}->{$section} or exists $master_hash->{$type}->{data}->{$section_vec} )
    {
        print $FHD "$section\n";
    }

    if ( exists $master_hash->{$type}->{data}->{$section} ) {

        foreach $var ( @{$master_hash->{$type}->{data}->{$section_order}} ) {

            print $FHD "    $master_hash->{$type}->{data}->{$section}->{$var} $var\n";
        }
    }

    if ( exists $master_hash->{$type}->{data}->{$section_vec} ) {

        foreach $var ( @{$master_hash->{$type}->{data}->{$section_vec_order}} ) {

            print $FHD "    $master_hash->{$type}->{data}->{$section_vec}->{$var} $var\n";
        }
    }

    if ( exists $master_hash->{$type}->{data}->{$section} or exists $master_hash->{$type}->{data}->{$section_vec} )
    {
        print $FHD "\n";
    }
}

1;
