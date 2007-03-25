#!/bin/sh

if [ $# -ne 2 ]
then
    echo `basename $0` id bumpage
    exit 1
fi

ID=$1
BUMPAGE=$2

TEMP_FILE=/tmp/`basename $0`.$$

MY_SQL="update interest_rate_vec set rate = rate + $BUMPAGE where id = $ID;"
echo $MY_SQL > $TEMP_FILE
RESULT=`mysql -u root $TRAD_DB < $TEMP_FILE`

DATE=`date '+%s'`


MY_SQL="update interest_rate set feed_published = $DATE where id = $ID;"
echo $MY_SQL > $TEMP_FILE
RESULT=`mysql -u root $TRAD_DB < $TEMP_FILE`


echo "Rates bumped"

#exit 0

