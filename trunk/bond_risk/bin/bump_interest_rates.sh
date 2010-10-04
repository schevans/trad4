#!/bin/sh

if [ $# -ne 2 ]
then
    echo `basename $0` id bumpage
    exit 1
fi

ID=$1
BUMP=$2

TEMP_FILE=/tmp/`basename $0`.$$

echo $SQLITE

MY_SQL="update ir_curve_input_rates set value = value + $BUMP where id = $ID; update object set need_reload=1 where id=$ID;"
echo $MY_SQL > $TEMP_FILE
RESULT=`$SQLITE $APP_DB < $TEMP_FILE`

send_reload.sh

echo "Rates bumped"

#exit 0

