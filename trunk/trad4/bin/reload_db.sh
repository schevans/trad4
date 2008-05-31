#!/bin/sh



if [ $# -ne 1 ]
then
    echo "reload_db.sh <data_dir>"
    exit 0
fi

echo "Reloading $TRAD4_DB"

echo "delete from object;" | $TRAD4_BIN/sqlite3 $TRAD4_DB

DATA_DIR=$1

cd $INSTANCE_ROOT/data/$DATA_DIR

for i in `ls *.sql`
do
    $TRAD4_ROOT/bin/runsql $i

    if [ $? != 0 ]
    then
        echo "Error encountered when loading $i. Exiting"
        exit 0
    fi
done

$TRAD4_ROOT/bin/runsql $INSTANCE_ROOT/gen/sql/object_types.sql

