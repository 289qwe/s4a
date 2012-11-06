# $OpenBSD: Makefile,v 1.60 2010/10/24 20:41:23 ajacoutot Exp $

VERSION = 		5.2.0
COMMENT =		S4A intrusion detection software
DISTNAME =		s4a-detector-${VERSION}

CATEGORIES =		net
HOMEPAGE =		http://www.cybernetica.eu
MAINTAINER =		Cybernetica AS

PERMIT_PACKAGE_CDROM =	Yes
PERMIT_PACKAGE_FTP =	Yes
PERMIT_DISTFILES_CDROM =Yes
PERMIT_DISTFILES_FTP =	Yes

#MASTER_SITES =		http://yourserver.address.com/~developer/	

PATCH_DIST_STRIP =	-p0

RUN_DEPENDS =		\
			misc/dialog \
			net/ipaudit \
			net/iplog \
			net/mrtg \
			net/nagios/nrpe \
			devel/p5-Class-Accessor \
			devel/p5-File-Sync \
			sysutils/p5-Filesys-Df \
			databases/p5-GDBM_File \
			net/nagios/p5-Nagios-Plugin \
			net/p5-Net-CIDR \
			devel/p5-Params-Validate \
			sysutils/p5-Proc-ProcessTable \
			net/p5-RPC-XML \
			net/rrdtool,-perl \
			devel/p5-Time-modules \
			www/p5-WWW-Curl \
			lang/php/5.3,-dba \
			sysutils/dmidecode \
			net/snort \

PREFIX=/var/www

WRKDIST =		${WRKDIR}/tuvastaja

.include <bsd.port.mk>
