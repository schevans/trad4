#!/bin/sh

PID=`ps -ef | grep $INSTANCE | grep -v grep | grep -v mysql | awk '{print $2}'`

kill -10 $PID

