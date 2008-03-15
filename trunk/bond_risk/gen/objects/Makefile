# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk

CXX = g++

CXXFLAGS = -c -I$(INSTANCE_ROOT)/gen/objects -I$(TRAD4_ROOT)/objects -I$(INSTANCE_ROOT)/objects

COMPILE = $(CXX) $(CXXFLAGS)

OBJECTS = loader.o load_repo_trade.o load_interest_rate_feed.o load_currency_curves.o load_outright_trade.o load_bond.o

all : $(OBJECTS)

%.o : %.c
	$(COMPILE) $< -o $@

clean : 
	rm -f $(OBJECTS)

