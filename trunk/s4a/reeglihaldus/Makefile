
# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

INSTALL=/usr/bin/install
PREFIX?=/usr/local
SOURCE=.
TARGET=s4a-rulesm
SAMPLE=s4a.sample
PERL=$(PREFIX)/libdata/perl5/site_perl
MANSRC=$(TARGET).src
MANOUT=$(TARGET).0

all:
	echo "Available targets are: install"

install:
	mkdir -p $(PREFIX)/$(TARGET)/$(SAMPLE) $(PERL)/Parse
	$(INSTALL) $(SOURCE)/Snort.pm $(PERL)/Parse/
	$(INSTALL) $(SOURCE)/dumbpig $(PREFIX)/bin/
	$(INSTALL) $(SOURCE)/addsid.pl $(PREFIX)/bin/
	$(INSTALL) $(SOURCE)/$(SAMPLE)/oinkmaster.conf $(PREFIX)/$(TARGET)/$(SAMPLE)/
	
	chgrp -R wheel $(PREFIX)/$(TARGET)
	groff -Tascii -man man/$(MANSRC) > $(MANOUT)
	$(INSTALL) $(MANOUT) $(PREFIX)/man/cat8/
