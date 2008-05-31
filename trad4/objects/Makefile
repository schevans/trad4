# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk

CXX = g++

CXXFLAGS = -Wall

COMPILE = $(CXX) $(CXXFLAGS)

all : $(INSTANCE_ROOT)/bin/$(INSTANCE)

$(INSTANCE_ROOT)/bin/$(INSTANCE) : trad4.c
	$(COMPILE) trad4.c ../../sqlite-amalgamation-3.5.9/sqlite3.o -o $(INSTANCE_ROOT)/bin/$(INSTANCE) -lpthread -ldl -lmysqlclient 

clean : 
	rm -f $(OBJECTS)

