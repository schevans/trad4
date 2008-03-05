# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk

CXX = g++ 

CXXFLAGS = -O3

COMPILE = $(CXX) $(CXXFLAGS)

all: trad4.o feed.o

trad4.o: trad4.c
	g++ -c -o trad4.o trad4.c 

feed.o: feed.c
	g++ -c -o feed.o feed.c 

clean :
	rm -f trad4.o feed.o

