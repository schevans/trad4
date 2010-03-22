#!/bin/sh

if [ -f $APP_DB ]
then
    echo "Dropping $APP_DB..."
    rm $APP_DB
fi

echo "Loading all in $TRAD4_ROOT/sql..."

cd $TRAD4_ROOT/sql

for i in `ls *.table`
do
    echo "Loading $i"

    $TRAD4_ROOT/bin/lsql $i
done

echo "Loading all in $APP_ROOT/gen/sql..."

cd $APP_ROOT/gen/sql

for i in `ls *.table`
do
    echo "Loading $i"

    $TRAD4_ROOT/bin/lsql $i
done


