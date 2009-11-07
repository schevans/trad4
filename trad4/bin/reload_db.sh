#!/bin/sh

. $TRAD4_ROOT/trad4.conf > /dev/null

if [ $# -ne 1 ]
then
    echo "reload_db.sh <data_dir>"
    exit 0
fi

echo "Reloading $APP_DB"

echo "delete from object;" | $SQLITE $APP_DB

DATA_DIR=$1

if [ ! "$DATA_DIR" = "." ]
then
    cd $APP_ROOT/data/$DATA_DIR
fi

for i in `ls *.sql`
do
    echo "Loading $i.."

    $TRAD4_ROOT/bin/runsql $i

    if [ $? != 0 ]
    then
        echo "Error encountered when loading $i. Exiting"
        exit 0
    fi
done

echo "Loading object_types.."

$TRAD4_ROOT/bin/runsql $APP_ROOT/gen/sql/object_types.sql

