# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk

CXX = g++

CXXFLAGS = -Wall -c

COMPILE = $(CXX) $(CXXFLAGS)

all : trad4.o libtrad4.so

trad4.o: trad4.c
	$(COMPILE) trad4.c -o trad4.o

libtrad4.so: trad4.o
	$(CXX) -shared -Wl,-soname,libtrad4.so -o libtrad4.so trad4.o
	mv libtrad4.so $(INSTANCE_ROOT)/lib/.


clean : 
	rm -f libtrad4.so trad4.o

