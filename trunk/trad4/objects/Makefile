# Copyright (c) Steve Evans 2008
# steve@topaz.myzen.co.uk

COMPILE = $(CXX) $(CXXFLAGS)

all : trad4.o libtrad4.so sqlite3.o

trad4.o: trad4.c
	$(COMPILE) trad4.c -o trad4.o -I.

libtrad4.so: trad4.o
	$(CXX) -shared -Wl,-soname,libtrad4.so -o libtrad4.so trad4.o
	mv libtrad4.so $(APP_ROOT)/lib/.

sqlite3.o : sqlite3.c
	gcc -fPIC -c sqlite3.c -o sqlite3.o

clean : 
	rm -f libtrad4.so trad4.o $(APP_ROOT)/lib/libtrad4.so

