#!/bin/sh

# Copyright (c) Steve Evans 2007
# steve@topaz.myzen.co.uk
# This code is licenced under the LGPL. For details see $TRAD4_ROOT/LICENCE

echo "Starting objloc.."
$TRAD4_ROOT/bin/object_locator &

echo "Starting monitor.."
$TRAD4_ROOT/bin/monitor_trad4 &


