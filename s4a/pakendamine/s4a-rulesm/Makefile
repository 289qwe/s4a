# $OpenBSD: Makefile,v 1.54 2009/08/16 13:31:27 rui Exp $

VERSION=		4.6.1
COMMENT =		S4A rulesmanager software 
DISTNAME =		s4a-rulesm-${VERSION}

CATEGORIES =		net
HOMEPAGE =		http://www.cybernetica.eu
MAINTAINER =		Cybernetica AS

PERMIT_PACKAGE_CDROM =	Yes
PERMIT_PACKAGE_FTP =	Yes
PERMIT_DISTFILES_CDROM =Yes
PERMIT_DISTFILES_FTP =	Yes

#MASTER_SITES =		http://yourserver.address.com/~developer/	

PATCH_DIST_STRIP =	-p0

RUN_DEPENDS =           oinkmaster::net/oinkmaster \
			p5-Class-Accessor::devel/p5-Class-Accessor \
			p5-libwww::www/p5-libwww

PREFIX=/usr/local

WRKDIST =		${WRKDIR}/reeglihaldus

.include <bsd.port.mk>
