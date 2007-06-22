#!/bin/sh

rm /tmp/obj_loc.shmid

PID=`ps -ef | grep object_locator | grep -v grep | awk '{print $2}'`

kill -9 $PID

