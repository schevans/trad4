#!/bin/sh

# Copyright (c) Steve Evans 2007
# steve@topaz.myzen.co.uk
# This code is licenced under the LGPL. For details see $TRAD4_ROOT/LICENCE

cd $INSTANCE_ROOT/defs

for t4_file in `ls *.t4`
do

    NAME=`echo $t4_file | sed 's/\..*//'`

echo $t4_file | sed 's/\..*//'

    $TRAD4_ROOT/bin/generate_stubs.pl $NAME
done


$TRAD4_ROOT/bin/generate_common.pl
#$TRAD4_ROOT/bin/generate_macros.pl

