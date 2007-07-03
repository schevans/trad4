#!/bin/sh

# Copyright (c) Steve Evans 2007
# steve@topaz.myzen.co.uk
# This code is licenced under the LGPL. For details see $TRAD4_ROOT/LICENCE

for i in `ls $DATA_DIR/*.t4o`
do
$TRAD4_ROOT/bin/start_object.pl $i
sleep 1
done

