
# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

CFLAGS	= -g -W -Wall
LDFLAGS	= -g -lssl -lcrypto

PROGRAMS = patch_sign patch_verify 
INSTALL = /usr/bin/install
PREFIX? = /usr/local

all:	$(PROGRAMS)

key:
	./genpatchkey.sh
	echo Kopeeri s4apatch.key kuhu vaja!

strip:	all
	strip $(PROGRAMS)

clean:
	$(RM) *~ core *.o $(PROGRAMS)

install:all
	$(INSTALL) $(PROGRAMS) $(PREFIX)/bin/
