# $OpenBSD: Makefile,v 1.54 2009/08/16 13:31:27 rui Exp $

VERSION =		4.6.1
COMMENT =		S4A centralserver software
DISTNAME =		s4a-centre-${VERSION}

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

BUILD_DEPENDS =		::devel/uthash 

LIB_DEPENDS =		rrd.>=3::net/rrdtool \
			gd.>=20::graphics/gd
WANTLIB += c

RUN_DEPENDS =		\
			gd::graphics/gd \
			libnet::net/libnet/1.1 \
			metaauto::devel/metaauto \
			nrpe::net/nagios/nrpe \
			p5-Proc-ProcessTable::sysutils/p5-Proc-ProcessTable \
			p5-RPC-XML::net/p5-RPC-XML \
			p5-RRD::net/rrdtool,-perl \
			p5-WWW-Curl::www/p5-WWW-Curl \
			php5-pdo_sqlite::www/php5/extensions,-pdo_sqlite \
			php5-sqlite::www/php5/extensions,-sqlite \
			php5-xmlrpc::www/php5/extensions,-xmlrpc \
			
PREFIX=/var/www

WRKDIST =		${WRKDIR}/s4a-centre

.include <bsd.port.mk>