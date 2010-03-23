
# Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/

INCPATH = -I/usr/local/include -I/usr/include 
LIBPATH = -L/usr/local/lib -L/usr/X11R6/lib 
PROGRAMS = s4ad
S4ADOBJECTS = s4a_buffer.o s4a_pipeline.o 
COMMON = $(LIBPATH)  
CC = gcc
CFLAGS = -g -Wall $(INCPATH)

all: rm_programs $(PROGRAMS)

build: release

release: all
	strip $(PROGRAMS)

rm_programs:
	rm -f -- $(PROGRAMS)

clean:
	rm -rf -- *.o $(PROGRAMS) *.so *.core

s4ad: $(S4ADOBJECTS)
	$(CC) $(CFLAGS) -o $@ $(S4ADOBJECTS) $(COMMON) -lrrd  

