#!/bin/sh

PID=`ps -ef | grep $INSTANCE | grep -v grep | grep -v mysql | awk '{print $2}'`

if [ $PID ]
then
    kill -10 $PID
else
    echo "$INSTANCE not found in ps. Are you sure $INSTANCE is running?"
    exit 0
fi


