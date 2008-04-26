
CXX = g++

CXXFLAGS = -I$(INSTANCE_ROOT)/objects -I$(INSTANCE_ROOT)/gen/objects -I$(TRAD4_ROOT)/objects

COMPILE = $(CXX) $(CXXFLAGS) -c

SUBDIRS = $(INSTANCE_ROOT)/objects $(INSTANCE_ROOT)/gen/objects

all: objs black_scholes stock_trade_lib risk_free_rate_feed_lib


objs: 
	for dir in $(SUBDIRS); do cd $$dir; $(MAKE) all ; cd $(INSTANCE_ROOT); done

black_scholes: $(TRAD4_ROOT)/objects/trad4.c
	$(CXX) -o black_scholes $(TRAD4_ROOT)/objects/trad4.c -lpthread -L/usr/local/lib/mysql -lmysqlclient -ldl

stock_trade_lib: objects/stock_feed.o 
	g++ -shared -Wl,-soname,t4lib_3 -o lib/t4lib_3 objects/stock_feed.o -L/usr/local/lib/mysql -lmysqlclient

risk_free_rate_feed_lib: objects/risk_free_rate_feed.o 
	g++ -shared -Wl,-soname,t4lib_2 -o lib/t4lib_2 objects/risk_free_rate_feed.o -L/usr/local/lib/mysql -lmysqlclient



clean: clean_objs clean_black_scholes

clean_objs:
	for dir in $(SUBDIRS); do cd $$dir; $(MAKE) clean; cd $(INSTANCE_ROOT); done

clean_black_scholes:
	rm -f black_scholes

opt:
	g++ -O3 -o black_scholes  /home/steve/src/trad4/objects/trad4.c /home/steve/src/trad4/objects/feed.c $(INSTANCE_ROOT)/objects/loader.c ./objects/option_feed.c ./objects/risk_free_rate_feed.c ./objects/stock_feed.c ./objects/stock_trade.c ./objects/rate_trade.c ./objects/bs_delta.c ./objects/kertn_d2.c ./objects/vega.c ./objects/theta.c ./objects/price.c ./objects/rho.c ./gen/objects/load_option_feed.c ./gen/objects/load_risk_free_rate_feed.c ./gen/objects/load_stock_feed.c ./gen/objects/load_stock_trade.c ./gen/objects/load_rate_trade.c ./gen/objects/load_bs_delta.c ./gen/objects/load_kertn_d2.c ./gen/objects/load_vega.c ./gen/objects/load_theta.c ./gen/objects/load_price.c ./gen/objects/load_rho.c -I./objects -I../trad4/objects -I./gen/objects -lpthread -L/usr/local/lib/mysql -lmysqlclient

