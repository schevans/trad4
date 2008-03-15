# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk

CXX = g++

CXXFLAGS = -c -I$(INSTANCE_ROOT)/gen/objects -I$(TRAD4_ROOT)/objects -I.

COMPILE = $(CXX) $(CXXFLAGS)

OBJECTS = bond.o interest_rate_feed.o currency_curves.o outright_trade.o repo_trade.o 

all : $(OBJECTS)

%.o : %.c
	$(COMPILE) $< -o $@

clean : 
	rm -f $(OBJECTS)

