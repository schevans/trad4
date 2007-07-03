#!/bin/sh

# Copyright (c) Steve Evans 2007
# steve@topaz.myzen.co.uk
# This code is licenced under the LGPL. For details see $TRAD4_ROOT/LICENCE

cd $INSTANCE_ROOT/defs

for t4_file in `ls *.t4`
do

    NAME=`echo $t4_file | sed 's/\..*//'`


    /home/steve/src/trad4/bin/generate_stubs.pl $NAME
done


/home/steve/src/trad4/bin/generate_common.pl

