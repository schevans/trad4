
CXX = g++

CXXFLAGS = -Wall -c -I$(INSTANCE_ROOT)/gen/objects -I.

COMPILE = $(CXX) $(CXXFLAGS)

OBJECTS = Object.o CalcObject.o FeedObject.o CalcObjectMgr.o CalcObjectAgg.o

all : $(OBJECTS)

%.o : %.cc
	$(COMPILE) $< -o $@

clean : 
	rm -f $(OBJECTS)

