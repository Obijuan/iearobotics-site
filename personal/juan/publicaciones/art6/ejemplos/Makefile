GHDL=ghdl
CC=gcc

all: hola_mundo

# Import of random function from the C library.
hola_mundo: test.o holac.o
	$(GHDL) -e -Wl,holac.o hola_mundo

test.o: hola_mundo.vhdl
	$(GHDL) -a $<

# Same as random_tb but in C.  
clean:
	rm -f hola_mundo *.o *.cf *~




