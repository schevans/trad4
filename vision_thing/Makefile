
COMPILE = $(CXX) $(CXXFLAGS) 

SUBDIRS = $(TRAD4_ROOT)/objects $(APP_ROOT)/objects $(APP_ROOT)/lib

all: objs vision_thing

vision_thing: objects/main.o
	g++ objects/main.o $(TRAD4_ROOT)/objects/sqlite3.o -o bin/vision_thing -ltrad4 -L$(TRAD4_ROOT)/objects -lpthread -ldl -L$(APP_ROOT)/lib -lgd -L$(APP_ROOT)/lib/3rd_party

objs:
	for dir in $(SUBDIRS); do cd $$dir; $(MAKE) all ; cd $(APP_ROOT); done


clean: clean_objs clean_vision_thing

clean_objs:
	for dir in $(SUBDIRS); do cd $$dir; $(MAKE) clean; cd $(APP_ROOT); done

clean_vision_thing:
	rm -f bin/vision_thing

