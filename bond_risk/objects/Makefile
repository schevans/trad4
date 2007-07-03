# Copyright (c) Steve Evans 2007
# steve@topaz.myzen.co.uk
# This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE
# 

CXX = g++

CXXFLAGS = -Wall -I$(INSTANCE_ROOT)/objects -I$(INSTANCE_ROOT)/gen/objects -I$(TRAD4_ROOT)/objects

COMPILE = $(CXX) $(CXXFLAGS) -c

OBJECTS = InterestRateFeed.o DiscountRate.o Bond.o OutrightTrade.o RepoTrade.o FxRateFeed.o OutrightTradeAgg.o RepoTradeAgg.o

all : $(OBJECTS)

%.o : %.cc
	$(COMPILE) $< -o $@

clean :
	rm -f $(OBJECTS)

