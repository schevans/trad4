#!/bin/sh



cd $APP_ROOT

. $APP_ROOT/$APP.conf

export TIMING_DEBUG=1
export BATCH_MODE=1

i=1

while [ $i -le 4096 ]
do
    export NUM_THREADS=$i

    echo "Working.."

    CONTEXT_SWITCHES_START=`cat /proc/stat | grep ctxt | sed 's/ctxt //'`

    RUN_TIME=`$APP | grep "All tiers ran" | awk -F' ' '{print $7}'`

    LOAD_AVERAGE=`top -b -n1 | grep "load average" | sed 's/^.*load average://' | awk -F, '{print $1}'`

    CONTEXT_SWITCHES_END=`cat /proc/stat | grep ctxt | sed 's/ctxt //'`
    
    CONTEXT_SWITCHES=`expr $CONTEXT_SWITCHES_END - $CONTEXT_SWITCHES_START`

    echo "$i,$LOAD_AVERAGE,$RUN_TIME,$CONTEXT_SWITCHES" >> benchmark.log.$$

    echo "$i,$LOAD_AVERAGE,$RUN_TIME,$CONTEXT_SWITCHES"

    i=`expr $i \* 2`

    echo "Sleeping.."
    sleep 10

done

echo Done

