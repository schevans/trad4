#!/bin/sh

# Copyright (c) Steve Evans 2007
# steve@topaz.myzen.co.uk
# This code is licenced under the LGPL. For details see $TRAD4_ROOT/LICENCE

$TRAD4_ROOT/bin/reset_shmem

sleep 1

$TRAD4_ROOT/bin/reset_obj_loc.sh

PID=`ps -ef | grep monitor_trad4 | grep -v grep | awk '{print $2}'`

kill -9 $PID

