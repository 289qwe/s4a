
# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

INSTALL=/bin/cp -r
PREFIX?=/usr/local
SOURCE=ca
TARGET=s4a-ca
MANSRC=$(TARGET).src
MANOUT=$(TARGET).0

all:
	echo "Available targets are: install"

install:
	$(INSTALL) $(SOURCE) $(PREFIX)/$(TARGET)
	chgrp -R wheel $(PREFIX)/$(TARGET)
	groff -Tascii -man man/$(MANSRC) > $(MANOUT)
	$(INSTALL) $(MANOUT) $(PREFIX)/man/cat8/
