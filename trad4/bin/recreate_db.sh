#!/bin/sh

SQL=$TRAD4_ROOT/sql
GSQL=$APP_ROOT/gen/sql
LSQL=$TRAD4_ROOT/bin/lsql

if [ ! -d $GSQL ]
then
    echo "Error: $GSQL not found. Have you run the precompiler?"
    exit 1
fi

if [ -f $APP_DB ]
then
    echo "Dropping $APP_DB..."
    rm $APP_DB
fi

echo "Loading all in $SQL..."

cd $SQL

for i in `ls *.table`
do
    echo "Loading $i"

    $LSQL $i
done

echo "Loading all in $GSQL..."

cd $GSQL

for i in `ls *.table`
do
    echo "Loading $i"

    $LSQL $i
done


