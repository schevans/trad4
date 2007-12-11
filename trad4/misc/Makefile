
CXX = g++

CXXFLAGS = -Wall

COMPILE = $(CXX) $(CXXFLAGS) -c 

OBJ_LOC = ../objects
BIN = ../bin

all: object object_locator object_viewer reset_shmem monitor_trad4

object: object.o $(OBJ_LOC)/*.o
	$(CXX) -I/usr/local/include  object.o $(OBJ_LOC)/*.o $(INSTANCE_ROOT)/gen/objects/*.o $(INSTANCE_ROOT)/objects/*.o -o $(BIN)/object 

object.o: object.c
	$(COMPILE) -I$(OBJ_LOC) -I$(INSTANCE_ROOT)/objects -I$(INSTANCE_ROOT)/gen/objects -o object.o -c object.c

object_locator: object_locator.c
	$(CXX)  -o $(BIN)/object_locator object_locator.c

reset_object: reset_object.c
	$(CXX) -I$(TRAD4_ROOT)/objects  -o $(BIN)/reset_object reset_object.c

reset_shmem: reset_shmem.c
	$(CXX) -I$(TRAD4_ROOT)/objects  -o $(BIN)/reset_shmem reset_shmem.c

monitor_trad4: monitor_trad4.c
	$(CXX) -I$(TRAD4_ROOT)/objects  -o $(BIN)/monitor_trad4 monitor_trad4.c

halt_object: halt_object.c
	$(CXX) -I$(TRAD4_ROOT)/objects  -o $(BIN)/halt_object halt_object.c

object_viewer: viewer.cc
	gcc  -o $(BIN)/object_viewer viewer.cc  `pkg-config gtkmm-2.4 --libs --cflags`

clean:
	rm -f object.o $(BIN)/object $(BIN)/object_locator $(BIN)/object_viewer
