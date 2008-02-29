# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk

CXX = g++

CXXFLAGS = -c -I$(TRAD4_ROOT)/objects

COMPILE = g++ -c -I$(TRAD4_ROOT)/objects

OBJECTS = bond.o interest_rate_feed.o discount_rate.o 

all : $(OBJECTS)

%.o : %.c
	g++ -c -I$(TRAD4_ROOT)/objects $< -o $@

clean : 
	rm -f $(OBJECTS)

