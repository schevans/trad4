# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk

CXX = g++

CXXFLAGS = -c -I$(TRAD4_ROOT)/objects

COMPILE = $(CXX) $(CXXFLAGS)

OBJECTS = ../trad4/objects/trad4.o ../trad4/objects/feed.o ./objects/bond.o ./objects/interest_rate_feed.o ./objects/currency_curves.o ./objects/loader.o ./objects/outright_trade.o ./objects/repo_trade.o ./objects/load_bond.o  ./objects/load_interest_rate_feed.o ./objects/load_currency_curves.o ./objects/load_outright_trade.o ./objects/load_repo_trade.o

SUBDIRS = $(INSTANCE_ROOT)/objects objects

all: objs bond_risk

objs:
	for dir in $(SUBDIRS); do cd $$dir; $(MAKE) all ; cd $(TRAD4_ROOT); done

clean: clean_objs clean_bond_risk

clean_objs:
	for dir in $(SUBDIRS); do cd $$dir; $(MAKE) clean; cd $(TRAD4_ROOT); done

clean_bond_risk:
	rm -f bond_risk

bond_risk: $(OBJECTS)
	$(CXX) -o bond_risk $(OBJECTS) -lpthread -L/usr/local/lib/mysql -lmysqlclient

opt:
	g++ -O3 -o  bond_risk ../trad4/objects/trad4.c ../trad4/objects/feed.c ./objects/bond.c ./objects/interest_rate_feed.c ./objects/currency_curves.c ./objects/loader.c ./objects/outright_trade.c ./objects/repo_trade.c ./objects/load_bond.c  ./objects/load_interest_rate_feed.c ./objects/load_currency_curves.c ./objects/load_outright_trade.c ./objects/load_repo_trade.c -I./objects -I../trad4/objects  -lpthread -L/usr/local/lib/mysql -lmysqlclient
