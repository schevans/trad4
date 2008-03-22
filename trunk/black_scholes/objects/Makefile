
CXX = g++

CXXFLAGS = -I$(INSTANCE_ROOT)/objects -I$(INSTANCE_ROOT)/gen/objects -I$(TRAD4_ROOT)/objects

COMPILE = $(CXX) $(CXXFLAGS) -c

OBJECTS = loader.o option_feed.o risk_free_rate_feed.o stock_feed.o rate_trade.o stock_trade.o bs_delta.o theta.o kertn_pd2.o vega.o gamma.o sn_pd1.o rho.o price.o listener.o

all : $(OBJECTS)

%.o : %.c
	$(COMPILE) $< -o $@

clean :
	rm -f $(OBJECTS)

