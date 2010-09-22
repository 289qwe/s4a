# $OpenBSD: Makefile,v 1.54 2009/08/16 13:31:27 rui Exp $

VERSION = 		4.7.2
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
			dialog::misc/dialog \
			ipaudit::net/ipaudit \
			iplog::net/iplog \
			mrtg::net/mrtg \
			nrpe::net/nagios/nrpe \
			p5-Class-Accessor::devel/p5-Class-Accessor \
			p5-File-Sync::devel/p5-File-Sync \
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

PREFIX=/var/www

WRKDIST =		${WRKDIR}/tuvastaja

.include <bsd.port.mk>
