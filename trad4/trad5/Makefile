# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk

CXX = g++

CXXFLAGS = -c -O3

COMPILE = $(CXX) $(CXXFLAGS)

OBJECTS = trad5.o bond.o discount_rate.o interest_rate_feed.o

trad5: $(OBJECTS)
	$(CXX) -o trad5 $(OBJECTS) -lpthread

%.o : %.c
	$(COMPILE) $< -o $@

clean :
	rm -f $(OBJECTS) trad5

