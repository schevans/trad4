
all: stock_feed.o risk_free_rate_feed.o

stock_feed.o: stock_feed.c
	g++ -I/home/steve/src/black_scholes/objects -I/home/steve/src/black_scholes/gen/objects -I/home/steve/src/trad4/objects -c stock_feed.c -o stock_feed.o

risk_free_rate_feed.o: risk_free_rate_feed.c
	g++ -I/home/steve/src/black_scholes/objects -I/home/steve/src/black_scholes/gen/objects -I/home/steve/src/trad4/objects -c risk_free_rate_feed.c -o risk_free_rate_feed.o

clean :
	rm -f *.o


