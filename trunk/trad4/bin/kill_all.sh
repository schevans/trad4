# Copyright (c) Steve Evans 2007
# steve@topaz.myzen.co.uk
# This code is licenced under the LGPL. For details see $TRAD4_ROOT/LICENCE


for i in `ps -ef | grep steve | grep object | grep -v object_locator | grep -v object_viewer | grep " 1 " | awk '{print $2}'`; do kill -1 $i; done

