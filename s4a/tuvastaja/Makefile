
# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

INSTALL=/bin/cp -r
PREFIX?=/var/www
WUI=s4a
S=snort
C=configurator
I=ipcounter
N=nrpe
K=keygen
U=updater

all:
	echo "Available targets are: install"

install:
	mkdir -p $(PREFIX)/htdocs/$(WUI)
	mkdir -p $(PREFIX)/tuvastaja/$(S)
	mkdir -p $(PREFIX)/tuvastaja/$(C)
	mkdir -p $(PREFIX)/tuvastaja/$(I)
	mkdir -p $(PREFIX)/tuvastaja/$(N)
	mkdir -p $(PREFIX)/tuvastaja/$(K)
	mkdir -p $(PREFIX)/tuvastaja/$(U)

	$(INSTALL) $(WUI) $(PREFIX)/htdocs/
	$(INSTALL) $(S) $(C) $(I) $(N) $(K) $(U) $(PREFIX)/tuvastaja/
	chgrp -R wheel $(PREFIX)/htdocs/$(WUI) $(PREFIX)/tuvastaja 
