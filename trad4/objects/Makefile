
CXX = g++

CXXFLAGS = -Wall -c -I$(INSTANCE_ROOT)/gen/objects

COMPILE = $(CXX) $(CXXFLAGS)

OBJECTS = Object.o CalcObject.o FeedObject.o CalcObjectVec.o

all : $(OBJECTS)

%.o : %.cc
	$(COMPILE) $< -o $@

clean : 
	rm -f $(OBJECTS)

