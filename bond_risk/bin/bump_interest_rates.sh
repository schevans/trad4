#!/bin/sh

if [ $# -ne 2 ]
then
    echo `basename $0` id bumpage
    exit 1
fi

ID=$1
BUMPAGE=$2

TEMP_FILE=/tmp/`basename $0`.$$

MY_SQL="update interest_rate_feed_data set rate = rate + $BUMPAGE where id = $ID;"
echo $MY_SQL > $TEMP_FILE
RESULT=`mysql -u root trad4 < $TEMP_FILE`


$INSTANCE_ROOT/misc/load_interest_rate $ID

echo "Rates bumped"

#exit 0

