# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk

CXX = g++

CXXFLAGS = -c

COMPILE = $(CXX) $(CXXFLAGS)

OBJECTS = trad4.o feed.o

all : $(OBJECTS)

%.o : %.c
	$(COMPILE) $< -o $@

clean : 
	rm -f $(OBJECTS)

