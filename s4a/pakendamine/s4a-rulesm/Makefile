# $OpenBSD: Makefile,v 1.54 2009/08/16 13:31:27 rui Exp $

VERSION=		4.6.1
COMMENT =		S4A rulesmanager software 
DISTNAME =		s4a-rulesm-${VERSION}

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

RUN_DEPENDS =           oinkmaster::net/oinkmaster \
			p5-Class-Accessor::devel/p5-Class-Accessor \
			p5-libwww::www/p5-libwww

PREFIX=/usr/local

WRKDIST =		${WRKDIR}/reeglihaldus

.include <bsd.port.mk>
