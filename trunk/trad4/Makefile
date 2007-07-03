
# Copyright (c) Steve Evans 2007
# steve@topaz.myzen.co.uk
# This code is licenced under the LGPL. For details see $TRAD4_ROOT/LICENCE


SUBDIRS = $(INSTANCE_ROOT)/objects $(INSTANCE_ROOT)/gen/objects objects misc

all:
	for dir in $(SUBDIRS); do cd $$dir; $(MAKE) all ; cd $(TRAD4_ROOT); done

viewers:
	cd $(INSTANCE_ROOT)/gen/viewer; make; cd -

clean:
	for dir in $(SUBDIRS); do cd $$dir; $(MAKE) clean; cd $(TRAD4_ROOT); done
