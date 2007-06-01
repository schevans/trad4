#!/bin/sh

for i in `ls $DATA_DIR/*.t4o`
do
$TRAD4_ROOT/bin/start_object.pl $i
sleep 1
done

