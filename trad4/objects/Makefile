
CXX = g++

CXXFLAGS = -Wall -c

COMPILE = $(CXX) $(CXXFLAGS)

OBJECTS = Object.o CalcObject.o FeedObject.o

all : $(OBJECTS)

%.o : %.cc
	$(COMPILE) $< -o $@

clean : 
	rm -f $(OBJECTS)

