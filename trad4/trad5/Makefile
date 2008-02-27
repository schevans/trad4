# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk

CXX = g++

CXXFLAGS = -c

COMPILE = $(CXX) $(CXXFLAGS)

OBJECTS = trad5.o bond.o discount_rate.o interest_rate_feed.o

trad5: $(OBJECTS)
	$(CXX) -o trad5 $(OBJECTS) -lpthread

trad5.o: trad5.c
	$(CXX) -c -o trad5.o trad5.c

bond.o: bond.c
	$(COMPILE) -o bond.o bond.c 

discount_rate.o: discount_rate.c
	$(COMPILE) -o discount_rate.o discount_rate.c 

interest_rate_feed.o: interest_rate_feed.c
	$(COMPILE) -o interest_rate_feed.o interest_rate_feed.c 

clean :
	rm -f $(OBJECTS) trad5

