
CXX = g++

CXXFLAGS = -Wall

COMPILE = $(CXX) $(CXXFLAGS) -c 

OBJ_LOC = ../objects
BIN = ../bin

all: load_interest_rate

load_interest_rate: load_interest_rate.c
	g++ -o load_interest_rate load_interest_rate.c -I../objects -I../../trad4/objects -L/usr/local/lib/mysql -lmysqlclient

