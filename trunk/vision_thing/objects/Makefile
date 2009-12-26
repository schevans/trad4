
COMPILE = $(CXX) $(CXXFLAGS)

all: main.o  input.o monitor.o neuron.o generate_fonts

main.o: main.c
	$(COMPILE) main.c -I$(TRAD4_ROOT)/objects -I$(APP_ROOT)/lib/3rd_party

generate_fonts: generate_fonts.c
	g++ -Wall generate_fonts.c -I$(APP_ROOT)/lib/3rd_party -L$(APP_ROOT)/lib/3rd_party -lgd -o generate_fonts

input.o: input.c ../gen/objects/input_wrapper.c
	$(COMPILE) -I$(APP_ROOT)/objects -I$(APP_ROOT)/gen/objects -I$(TRAD4_ROOT)/objects input.c -o input.o -I$(APP_ROOT)/lib/3rd_party

monitor.o: monitor.c ../gen/objects/monitor_wrapper.c
	$(COMPILE) -I$(APP_ROOT)/objects -I$(APP_ROOT)/gen/objects -I$(TRAD4_ROOT)/objects monitor.c -o monitor.o -I$(APP_ROOT)/lib/3rd_party

neuron.o: neuron.c ../gen/objects/neuron_wrapper.c
	$(COMPILE) -I$(APP_ROOT)/objects -I$(APP_ROOT)/gen/objects -I$(TRAD4_ROOT)/objects neuron.c -o neuron.o -I$(APP_ROOT)/lib/3rd_party


clean:
	rm -f *.o

