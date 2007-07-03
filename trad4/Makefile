

SUBDIRS = $(INSTANCE_ROOT)/objects $(INSTANCE_ROOT)/gen/objects objects misc

all:
	for dir in $(SUBDIRS); do cd $$dir; $(MAKE) all ; cd $(TRAD4_ROOT); done

viewers:
	cd $(INSTANCE_ROOT)/gen/viewer; make; cd -

clean:
	for dir in $(SUBDIRS); do cd $$dir; $(MAKE) clean; cd $(TRAD4_ROOT); done
