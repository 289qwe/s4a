
-- Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/

CREATE TABLE Organisation ( 
	name char,
	sid integer PRIMARY KEY 
);

CREATE TABLE Tuvastaja ( 
	active boolean,
	droprate integer,
	errormask integer,
	lastvisit timestamp,
	lastvisitMAC char,
	lastvisitIP char,
	lastvisitrulever timestamp,
	lastvisitver char,
	longname char,
	shortname char,
	tuvastaja_org integer CONSTRAINT fk_tuvastaja_org REFERENCES Organisation(sid), 
	updated_by char,
	sid integer PRIMARY KEY 
);

CREATE TABLE Certificate ( 
	active boolean,
	updated_by char,
	activity timestamp,
	cert_tuvastaja integer CONSTRAINT fk_cert_tuvastaja REFERENCES Tuvastaja(sid),
	notAfter timestamp,
	notBefore timestamp,
	serial char PRIMARY KEY
);
