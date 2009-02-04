#!/bin/sh

NUM_APPS=`ps -ef | grep $APP | grep -v grep | grep -v sqlite3 | grep -v send_reload | wc -l`

if [ $NUM_APPS = 0 ]
then
    echo "Error: $APP not found under ps. Are you sure it's running?"
    exit 0
fi

if [ $NUM_APPS != 1 ]
then
    echo "Error: More than one $APP found running under ps. Suggest you kill both and start again."
    exit 0
fi

PID=`ps -ef | grep $APP | grep -v grep | grep -v sqlite3 | grep -v send_reload | awk '{print $2}'`

if [ $PID ]
then
    kill -10 $PID
fi


