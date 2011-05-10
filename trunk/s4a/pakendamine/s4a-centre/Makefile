# $OpenBSD: Makefile,v 1.60 2010/10/24 20:41:23 ajacoutot Exp $

VERSION =		4.9.0
COMMENT =		S4A centralserver software
DISTNAME =		s4a-centre-${VERSION}

CATEGORIES =		net
HOMEPAGE =		http://www.cybernetica.eu
MAINTAINER =		Cybernetica AS

PERMIT_PACKAGE_CDROM =	Yes
PERMIT_PACKAGE_FTP =	Yes
PERMIT_DISTFILES_CDROM =Yes
PERMIT_DISTFILES_FTP =	Yes

#MASTER_SITES =		http://yourserver.address.com/~developer/	

PATCH_DIST_STRIP =	-p0

BUILD_DEPENDS =		devel/uthash 

WANTLIB += c rrd>=3.0 gd>=20.35

RUN_DEPENDS =		\
			graphics/gd \
			net/libnet/1.1 \
			net/p5-RPC-XML \
			net/rrdtool,-perl \
			www/php5/extensions,-pdo_sqlite \
			www/php5/extensions,-sqlite \
			www/php5/extensions,-xmlrpc \
			
PREFIX=/var/www

WRKDIST =		${WRKDIR}/s4a-centre

.include <bsd.port.mk>
