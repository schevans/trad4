# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk

CXX = g++

CXXFLAGS = -c

COMPILE = $(CXX) $(CXXFLAGS)

OBJECTS = trad4.o feed.o

all : trad4.o

trad4.o : trad4.c
	g++ trad4.c -o $(INSTANCE_ROOT)/bin/black_scholes -lpthread -ldl -lmysqlclient

clean : 
	rm -f $(OBJECTS)

