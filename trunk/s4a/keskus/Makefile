
# Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/

INSTALL=/bin/cp -r
PREFIX?=/var/www
CONF=conf
CONFSERV=confserv
CONFSERVLOGS=confserv-logs
DATABASE=database
KEYGEN=keygen
SIGSUPPORTER=sigsupporter
S4AVIEW=s4a-view
S4AD=s4ad
S4ADRAW=s4a-draw
MANSRC=s4a-centre.src
MANOUT=s4a-centre.0
MAN=${PREFIX}/../../usr/local/man/cat8
BIN=${PREFIX}/../../usr/local/bin
S4ACENTRE=${PREFIX}/../../usr/local/s4a-centre

all:
	@(cd $(S4AD); $(MAKE) all)
	@(cd $(S4ADRAW); $(MAKE) all)

install:
	mkdir -p $(PREFIX)/$(CONF)
	mkdir -p $(PREFIX)/$(CONFSERV)
	mkdir -p $(PREFIX)/$(CONFSERVLOGS)
	mkdir -p $(PREFIX)/$(DATABASE)
	mkdir -p $(S4ACENTRE)/$(KEYGEN)
	mkdir -p $(S4ACENTRE)/$(SIGSUPPORTER)
	mkdir -p $(PREFIX)/$(S4AVIEW)
	mkdir -p $(PREFIX)/$(S4AVIEW)/detectors
	mkdir -p $(PREFIX)/$(S4AVIEW)/sigs
	mkdir -p $(PREFIX)/tmp
	mkdir -p $(PREFIX)/etc

	$(INSTALL) $(CONF) $(CONFSERV) $(DATABASE) $(S4AVIEW) $(PREFIX)/
	$(INSTALL) $(KEYGEN) $(SIGSUPPORTER) $(S4ACENTRE)/
	chgrp -R wheel $(PREFIX)/$(CONF) $(PREFIX)/$(CONFSERV) $(PREFIX)/$(CONFSERVLOGS) \
	$(PREFIX)/$(DATABASE) $(S4ACENTRE)/$(KEYGEN) $(S4ACENTRE)/$(SIGSUPPORTER) $(PREFIX)/$(S4AVIEW)
	chgrp www $(PREFIX)/tmp
	chgrp www $(PREFIX)/$(S4AVIEW)/detectors
	chgrp www $(PREFIX)/$(S4AVIEW)/sigs

	install $(S4AD)/$(S4AD) $(BIN)/
	install $(S4ADRAW)/$(S4ADRAW) $(BIN)/

	groff -Tascii -man man/$(MANSRC) > $(MANOUT)
	$(INSTALL) $(MANOUT) $(MAN)/$(MANOUT)
	$(INSTALL) $(MANOUT) $(MAN)/s4a-sig-current.0
	$(INSTALL) $(MANOUT) $(MAN)/s4a-sig-revoke.0
	$(INSTALL) $(MANOUT) $(MAN)/s4a-sig-check.0
	$(INSTALL) $(MANOUT) $(MAN)/s4a-sig-check-current.0
	$(INSTALL) $(MANOUT) $(MAN)/s4a-sig-apply.0
