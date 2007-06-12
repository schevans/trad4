
CXX = g++

CXXFLAGS = -Wall -I/home/steve/src/black_scholes/objects -I/home/steve/src/black_scholes/gen/objects -I/home/steve/src/trad4/objects

COMPILE = $(CXX) $(CXXFLAGS) -c

OBJECTS = RiskFreeRateFeed.o StockFeed.o Trade.o

all : $(OBJECTS)

%.o : %.cc
	$(COMPILE) $< -o $@

clean :
	rm -f $(OBJECTS)

