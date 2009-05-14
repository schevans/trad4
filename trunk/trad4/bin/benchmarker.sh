#!/bin/sh



cd $APP_ROOT

. $APP_ROOT/$APP.conf

export TIMING_DEBUG=1
export BATCH_MODE=1

i=1

while [ $i -le 4096 ]
do
    export NUM_THREADS=$i

    RUN_TIME=`$APP | grep "All tiers ran" | awk -F' ' '{print $7}'`

    LOAD_AVERAGE=`top -b -n1 | grep "load average" | sed 's/^.*load average://' | awk -F, '{print $1}'`

    echo "$i,$LOAD_AVERAGE,$RUN_TIME" >> benchmark.log.$$

    echo "$i,$RUN_TIME"

    i=`expr $i \* 2`

    echo "Sleeping.."
    sleep 100

done

