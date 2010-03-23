
# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

INCPATH = -I/usr/local/include -I/usr/include 
LIBPATH = -L/usr/local/lib -L/usr/X11R6/lib -L.
PROGRAMS = s4a-draw 
S4ADRAWOBJECTS = s4a-draw.o 
COMMON = $(LIBPATH)  
CC = gcc
CFLAGS = -O2 -Wall $(INCPATH)

all: rm_programs $(PROGRAMS)

build: release

release: all
	strip $(PROGRAMS)

rm_programs:
	rm -f -- $(PROGRAMS)

clean:
	rm -rf -- *.o $(PROGRAMS) *.so *.core

s4a-draw: $(S4ADRAWOBJECTS)
	$(CC) $(CFLAGS) -o $@ $(S4ADRAWOBJECTS) $(COMMON) -lrrd -lgd 

