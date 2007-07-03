#!/bin/sh

# Copyright (c) Steve Evans 2007
# steve@topaz.myzen.co.uk
# This code is licenced under the LGPL. For details see $TRAD4_ROOT/LICENCE

rm /tmp/obj_loc.shmid

PID=`ps -ef | grep object_locator | grep -v grep | awk '{print $2}'`

kill -9 $PID

