# Copyright (c) Steve Evans 2008
# schevans@users.sourceforge.net
#

package PreComp::Docco;

use Data::Dumper;
use warnings;

sub Generate($) {
    my $master_hash = shift;

    my $app_name = $ENV{APP};
    my $trad4_version = $ENV{TRAD4_VERSION};

    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::DoccoRoot()."$app_name.html");
    if( ! $FHD ) { return; }

    print $FHD "\n";
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
    print $FHD "<td>Application version</td>\n";
    print $FHD "<td></td>\n";
    print $FHD "</tr>\n";
    print $FHD "<tr>\n";
    print $FHD "<td>Trad4 version</td>\n";
    print $FHD "<td></td>\n";
    print $FHD "</tr>\n";
    print $FHD "<tr>\n";
    print $FHD "<td>Document version</td>\n";
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
    print $FHD "<li><a href=\"#usage\">Usage</a></li>\n";
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
    print $FHD "<h3>The abstract diagram</h3>\n";
    print $FHD "<p>\n";
    print $FHD "\n";
    print $FHD "</p>\n";
    print $FHD "<h3>The concrete diagram</h3>\n";
    print $FHD "<p>\n";
    print $FHD "\n";
    print $FHD "</p>\n";
    print $FHD "\n";
    print $FHD "<h2><a name=\"usage\">Usage</a></h2>\n";
    print $FHD "<h3>Running</h3>\n";
    print $FHD "<p>\n";
    print $FHD "To run the application:<br/>\n";

    print $FHD "1) Download and unpack the distribution<br/>\n";
    print $FHD "2) cd into trad4_v$trad4_version/$app_name:<br/>\n";
    print $FHD "</p>\n";
    print $FHD "<blockquote><pre>\$ cd trad4_v$trad4_version/$app_name</pre></blockquote>\n";
    print $FHD "3) Source $app_name.conf:<br/>\n";
    print $FHD "<blockquote><pre>$app_name\$ . ./$app_name.conf</pre></blockquote>\n";
    print $FHD "4) Start $app_name:<br/>\n";
    print $FHD "<blockquote><pre>$app_name\$ $app_name</pre></blockquote>\n";
    print $FHD "<p>\n";
    print $FHD "To increase or decrease the number of threads used (the default is 4), set NUM_THREADS and re-start the application:\n";
    print $FHD "</p>\n";
    print $FHD "<blockquote><pre>\$ export NUM_THREADS=64\n"; 
    print $FHD "\$ $app_name</pre></blockquote>\n";
    print $FHD "<h3>Updating</h3>\n";
    print $FHD "<p>\n";
    print $FHD "To update a running system, log into the database:\n";
    print $FHD "</p>\n";
    print $FHD "<blockquote><pre>\$ t4db\n"; 
    print $FHD "SQL></pre></blockquote>\n";
    print $FHD "<p>\n";
    print $FHD "And make any required updates. Then instruct the running application to collect these changes by using send_reload.sh:\n";
    print $FHD "</p>\n";
    print $FHD "<blockquote><pre>\$ send_reload.sh</pre></blockquote>\n";
    print $FHD "\n";
    print $FHD "</body>\n";
    print $FHD "</html>\n";

    PreComp::Utilities::CloseFile();

}

sub PrintT4Section($$$$) {
    my $master_hash = shift;
    my $section_type = shift;
    my $type = shift;
    my $is_ul_list = shift;
    my $FHD = shift;

    my $section = $section_type;
    my $section_vec = $section_type."_vec";
    my $section_order = $section_type."_order";
    my $section_vec_order = $section_type."_vec_order";

    if ( keys %{$master_hash->{$type}->{data}->{$section}} or keys %{$master_hash->{$type}->{data}->{$section_vec}} )
    {
        if ( $is_ul_list ) {

            print $FHD "<li>$section:\n";
        }
        else {
    
            print $FHD "$section\n";
        }
    }

    if ( ( keys %{$master_hash->{$type}->{data}->{$section}} || keys %{$master_hash->{$type}->{data}->{$section_vec}} ) && $is_ul_list ) {

        print $FHD "    <ul>\n";
    }

    if ( exists $master_hash->{$type}->{data}->{$section} ) {

        foreach $var ( @{$master_hash->{$type}->{data}->{$section_order}} ) {

            if ( $is_ul_list ) {

                print $FHD "    <li>$var</li>\n";
            }
            else {

                print $FHD "    $master_hash->{$type}->{data}->{$section}->{$var} $var\n";  
            }
        }
    }

    if ( exists $master_hash->{$type}->{data}->{$section_vec} ) {

        foreach $var ( @{$master_hash->{$type}->{data}->{$section_vec_order}} ) {

            if ( $is_ul_list ) {

                print $FHD "    <li>$var</li>\n";
            }
            else {

                print $FHD "    $master_hash->{$type}->{data}->{$section_vec}->{$var} $var\n";
            }
        }
    }

    if ( ( keys %{$master_hash->{$type}->{data}->{$section}} or keys %{$master_hash->{$type}->{data}->{$section_vec}} ) and $is_ul_list ) {

        print $FHD "    </ul>\n";
        print $FHD "</li>\n";
    }

    if ( keys %{$master_hash->{$type}->{data}->{$section}} or keys %{$master_hash->{$type}->{data}->{$section_vec}} )
    {
        print $FHD "\n";
    }
}

sub GenerateAbstractDiagram($) {
    my $master_hash = shift;

    print "Generating abstract graph..\n";

    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::DoccoRoot()."abstract.dot");
    if( ! $FHD ) { return; }

    print $FHD "digraph abstract {\n";
    print $FHD "\n";
    print $FHD "    rankdir=TD;\n";
    print $FHD "    {\n";
    print $FHD "        node [shape=plaintext, fontsize=16 ]\n";
    print $FHD "\n";

    my $isIoI=0;
    my %tiers;
    my $max_tier=0;

    foreach $type ( keys %{$master_hash} ) {

        if ( exists $master_hash->{$type}->{type_id} ) {

            if ( $master_hash->{$type}->{tier} == 0 ) {

                $isIoI =1;
                
            }
            else {

                $tiers{$master_hash->{$type}->{tier}} = 1;

                if ( $master_hash->{$type}->{tier} > $max_tier ) {
                    
                    $max_tier = $master_hash->{$type}->{tier};
                }
            }
        }
    }

    if ( $isIoI ) {

        print $FHD "        Tm -> Tn [ dir=back ]\n";
    }
    else {

        print $FHD "        T$max_tier";

        foreach $tier ( reverse sort ( keys %tiers )) {

            if ( $tier != $max_tier ) { 

                print $FHD " -> T$tier";
            }
            
        }

        print $FHD " [ dir=back ]\n";
    }

    print $FHD "    }\n";
    print $FHD "\n";

    %tiers = ();

    foreach $type ( keys %{$master_hash} ) {

        if ( exists $master_hash->{$type}->{type_id} ) {

            if ( $master_hash->{$type}->{tier} == 0 ) {

                print $FHD "    $type  [label=\"$type\" shape=box] \n";

                if ( scalar( @{$master_hash->{$type}->{sub}->{order}}) ) {

                    push @{$tiers{2}}, $type;

                    foreach $var_name ( @{$master_hash->{$type}->{sub}->{order}} ) {

                        if ( PreComp::Utilities::IsArray( $var_name )) {

                            my $array_size = PreComp::Utilities::GetArraySize( $master_hash, $var_name );
                            $var_name = PreComp::Utilities::StripBrackets( $var_name );
                            $var_name = $var_name."[$array_size]";

                        }

                        my $sub_type = $type."_$var_name";

                        print $FHD "    $sub_type  [label=\"$var_name\" shape=box] \n";

                        print $FHD "    $type->$sub_type [dir=back]\n";
            
                        push @{$tiers{1}}, $sub_type;
                    }
                }
                else {
    
                    push @{$tiers{1}}, $type;
                }
            }
            else {

                print $FHD "    $type  [label=\"$type\" shape=box] \n";
    
                push @{$tiers{$master_hash->{$type}->{tier}}}, $type;

                foreach $var_name ( @{$master_hash->{$type}->{sub}->{order}} ) {

                    my $var_type = $master_hash->{$type}->{sub}->{data}->{$var_name};

                    print $FHD "    $type->$var_type [dir=back]\n";

                }
            }
        }
    }

    print $FHD "\n";

    foreach $tier ( keys %tiers ) {

        print $FHD "    {rank=same; ";

        foreach $type ( @{$tiers{$tier}} ) {

            print $FHD "$type ";
        }

        print $FHD "}\n";

    }

    print $FHD "\n";
    print $FHD "}\n";
    print $FHD "\n";
        

    PreComp::Utilities::CloseFile();
}

sub GenerateInheritanceDiagram($) {
    my $master_hash = shift;

    my $isIoI=0;

    foreach $type ( keys %{$master_hash} ) {

        if ( exists $master_hash->{$type}->{type_id} ) {

            if ( $master_hash->{$type}->{tier} == 0 ) {

                $isIoI =1;
                last;
            }
        }
    }

    if ( !$isIoI ) {

        return;
    }
    
    print "Generating inheritance graph..\n";

    my $FHD = PreComp::Utilities::OpenFile( PreComp::Constants::DoccoRoot()."inheritance.dot");
    if( ! $FHD ) { return; }

    print $FHD "digraph inheritance {\n";
    print $FHD "\n";

    my %tiers;
    my $max_tier=0;

    foreach $type ( keys %{$master_hash} ) {

        if ( exists $master_hash->{$type}->{type_id} ) {

            if ( $master_hash->{$type}->{tier} == 0 ) {

                print $FHD "    $type  [label=\"$type\" shape=diamond] \n";

                if ( $master_hash->{$type}->{implements} ne $type ) {

                    print $FHD "    $master_hash->{$type}->{implements} -> $type [dir=back ]\n";

                }
            }
        }
    }

    print $FHD "\n";
    print $FHD "}\n";
    print $FHD "\n";
        

    PreComp::Utilities::CloseFile();
}


1;

1;
