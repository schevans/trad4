#!/bin/sh



cd $APP_ROOT

. $APP_ROOT/$APP.conf

export TIMING_DEBUG=1
export BATCH_MODE=1

i=1

while [ $i -ne 128 ]
do
    echo $i

    export NUM_THREADS=$i

    echo -n "$i: " >> load.$$
    top -b -n1 | grep "load average" >> load.$$

    echo -n "$i: " >> timer.$$
    $APP | grep "All tiers ran" >> timer.$$
    
    i=`expr $i + 1`

done

