#!/bin/sh

NUM_APPS=`ps -C $APP | grep -v PID | wc -l`

if [ $NUM_APPS = 0 ]
then
    echo "Error: $APP not found under ps. Are you sure it's running?"
    exit 0
fi

if [ $NUM_APPS != 1 ]
then
    echo "Error: More than one $APP found running under ps. Suggest you kill them all and start again."
    exit 0
fi

PID=`ps -C $APP | grep -v PID | awk '{print $1}'`

if [ $PID ]
then
    kill -10 $PID
fi


