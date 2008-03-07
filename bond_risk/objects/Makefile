# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk

CXX = g++

CXXFLAGS = -c -I$(TRAD4_ROOT)/objects

COMPILE = g++ -c -I$(TRAD4_ROOT)/objects

OBJECTS = bond.o interest_rate_feed.o currency_curves.o loader.o outright_trade.o repo_trade.o load_repo_trade.o load_interest_rate_feed.o load_currency_curves.o load_outright_trade.o load_bond.o

all : $(OBJECTS)

%.o : %.c
	g++ -c -I$(TRAD4_ROOT)/objects $< -o $@

clean : 
	rm -f $(OBJECTS)

