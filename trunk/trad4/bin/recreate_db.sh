#!/bin/sh

cd $TRAD4_ROOT/sql

for i in `ls *.table`
do
    $TRAD4_ROOT/bin/lsql $i
done

cd $INSTANCE_ROOT/gen/sql

for i in `ls *.table`
do
    $TRAD4_ROOT/bin/lsql $i
done



