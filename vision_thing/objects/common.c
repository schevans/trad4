// Copyright (c) Steve Evans 2010
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

// This is a hack simply to get round the lack of support for strings in trad4.
// There are various workarounds, from (in the static section) char my_name[MAX_NAMES], but this 
// looks a bit ridiculous once rendered in the trad4 database ("H", "e", "l", "l", "o", etc.). 
// There's this approach as well of course. 
// Lastly, there's doing it properly, by adding support for std::string to trad4. 
// This is slated for v3.2, but I've done no investigation whatsoever so it may be trickier than I think.
void init_font_map( map<int, string>& font_map )
{
    font_map[0] = "LiberationSerif-Bold";
    font_map[1] = "Harabara";
    font_map[2] = "OptimusPrinceps";
}

