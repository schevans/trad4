# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk

CXX = g++

CXXFLAGS = -c -I$(TRAD4_ROOT)/objects

COMPILE = $(CXX) $(CXXFLAGS)

OBJECTS = ../trad4/objects/trad4.o ./objects/bond.o ./objects/interest_rate_feed.o ./objects/discount_rate.o ./objects/loader.o

SUBDIRS = $(INSTANCE_ROOT)/objects objects

all: objs trad_bond_risk

objs:
	for dir in $(SUBDIRS); do cd $$dir; $(MAKE) all ; cd $(TRAD4_ROOT); done

clean: clean_objs clean_trad_bond_risk

clean_objs:
	for dir in $(SUBDIRS); do cd $$dir; $(MAKE) clean; cd $(TRAD4_ROOT); done

clean_trad_bond_risk:
	rm -f trad_bond_risk

trad_bond_risk: $(OBJECTS)
	$(CXX) -o trad_bond_risk $(OBJECTS) -lpthread -I../trad4/objects

