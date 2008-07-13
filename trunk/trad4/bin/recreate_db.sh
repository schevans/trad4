#!/bin/sh

cd $TRAD4_ROOT/sql

for i in `ls *.table`
do
    $TRAD4_ROOT/bin/lsql $i
done

cd $APP_ROOT/gen/sql

for i in `ls *.table`
do
    $TRAD4_ROOT/bin/lsql $i
done

if [ -d $APP_ROOT/sql ] 
then

    cd $APP_ROOT/sql

    for i in `ls *.table`
    do
        $TRAD4_ROOT/bin/lsql $i
    done

fi



