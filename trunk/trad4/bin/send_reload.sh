#!/bin/sh

PID=`ps -ef | grep $APP | grep -v grep | grep -v sqlite3 | awk '{print $2}'`

if [ $PID ]
then
    kill -10 $PID
else
    echo "$INSTANCE not found in ps. Are you sure $INSTANCE is running?"
    exit 0
fi


