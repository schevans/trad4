# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk

CXX = g++

CXXFLAGS = -O3

COMPILE = $(CXX) $(CXXFLAGS)

OBJECTS = trad5.c bond.c discount_rate.c interest_rate_feed.c

trad5: $(OBJECTS)
	$(CXX) -o trad5 $(OBJECTS) -lpthread

clean :
	rm -f trad5

