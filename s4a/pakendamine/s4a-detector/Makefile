# $OpenBSD: Makefile,v 1.54 2009/08/16 13:31:27 rui Exp $

VERSION = 		4.6.8
COMMENT =		S4A intrusion detection software
DISTNAME =		s4a-detector-${VERSION}

CATEGORIES =		cyber
HOMEPAGE =		http://www.cyber.ee
MAINTAINER =		Cybernetica AS, www.cyber.ee	

PERMIT_PACKAGE_CDROM =	Yes
PERMIT_PACKAGE_FTP =	Yes
PERMIT_DISTFILES_CDROM =Yes
PERMIT_DISTFILES_FTP =	Yes

#MASTER_SITES =		http://ondatra.cyber.ee/~sven/	
MASTER_SITES =		http://ondatra.cyber.ee/~mattu/tuvastaja/

PATCH_DIST_STRIP =	-p0

RUN_DEPENDS =		\
			dialog::misc/dialog \
			ipaudit::net/ipaudit \
			iplog::net/iplog \
			lsof::sysutils/lsof \
			mrtg::net/mrtg \
			nagios-plugins-snmp::net/nagios/plugins,-snmp \
			nrpe::net/nagios/nrpe \
			p5-Class-Accessor::devel/p5-Class-Accessor \
			p5-Filesys-Df::sysutils/p5-Filesys-Df \
			p5-GDBM_File::databases/p5-GDBM_File \
			p5-Nagios-Plugin::net/nagios/p5-Nagios-Plugin \
			p5-Net-CIDR::net/p5-Net-CIDR \
			p5-Params-Validate::devel/p5-Params-Validate \
			p5-Proc-ProcessTable::sysutils/p5-Proc-ProcessTable \
                        p5-RPC-XML::net/p5-RPC-XML \
                        p5-RRD::net/rrdtool,-perl \
			p5-Time-modules::devel/p5-Time-modules \
                        p5-WWW-Curl::www/p5-WWW-Curl \
			php5-dba::www/php5/extensions,-dba \
			snort::net/snort \
			tcptraceroute::net/tcptraceroute 

PREFIX=/var/www

WRKDIST =		${WRKDIR}/tuvastaja

.include <bsd.port.mk>
