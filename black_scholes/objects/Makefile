
CXX = g++

CXXFLAGS = -Wall -I$(INSTANCE_ROOT)/objects -I$(INSTANCE_ROOT)/gen/objects -I$(TRAD4_ROOT)/objects

COMPILE = $(CXX) $(CXXFLAGS) -c

OBJECTS = RiskFreeRateFeed.o StockFeed.o Option.o OptionVec.o

all : $(OBJECTS)

%.o : %.cc
	$(COMPILE) $< -o $@

clean :
	rm -f $(OBJECTS)

