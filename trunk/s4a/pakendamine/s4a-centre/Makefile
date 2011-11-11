# $OpenBSD: Makefile,v 1.60 2010/10/24 20:41:23 ajacoutot Exp $

VERSION =		5.0.0
COMMENT =		S4A centralserver software
DISTNAME =		s4a-centre-${VERSION}

CATEGORIES =		net
HOMEPAGE =		http://www.cybernetica.eu
MAINTAINER =		Cybernetica AS

PERMIT_PACKAGE_CDROM =	Yes
PERMIT_PACKAGE_FTP =	Yes
PERMIT_DISTFILES_CDROM =Yes
PERMIT_DISTFILES_FTP =	Yes

#MASTER_SITES =                http://yourserver.address.com/~developer/

PATCH_DIST_STRIP =	-p0

BUILD_DEPENDS =		devel/uthash 

WANTLIB += c rrd>=3.0 gd>=20.35

RUN_DEPENDS =		\
			graphics/gd \
			net/libnet/1.1 \
			net/p5-RPC-XML \
			net/rrdtool,-perl \
			lang/php/5.3,-pdo_sqlite \
			lang/php/5.3,-sqlite \
			lang/php/5.3,-xmlrpc
			

CHROOT_DIR?=/var/www
PREFIX-web?=/var/www

WRKDIST =		${WRKDIR}/s4a-centre

post-install:
	${INSTALL_DATA_DIR} ${WRKINST}${CHROOT_DIR}/conf/s4a
	${INSTALL_DATA_DIR} ${WRKINST}${CHROOT_DIR}/conf/s4a.sample
	${INSTALL_DATA_DIR} ${WRKINST}${CHROOT_DIR}/confserv/signatures
	${INSTALL_DATA_DIR} ${WRKINST}${CHROOT_DIR}/confserv/patches
	${INSTALL_DATA_DIR} ${WRKINST}${CHROOT_DIR}/confserv-logs
	${INSTALL_DATA_DIR} ${WRKINST}${CHROOT_DIR}/database
	${INSTALL_DATA_DIR} ${PREFIX}/s4a-centre/keygen
	${INSTALL_DATA_DIR} ${PREFIX}/s4a-centre/sigsupporter
	${INSTALL_DATA_DIR} ${WRKINST}${CHROOT_DIR}/s4a-view/detectors
	${INSTALL_DATA_DIR} ${WRKINST}${CHROOT_DIR}/s4a-view/sigs
	${INSTALL_DATA_DIR} ${WRKINST}${CHROOT_DIR}/s4a-view/images
	${INSTALL_DATA_DIR} ${WRKINST}${CHROOT_DIR}/tmp
	${INSTALL_DATA_DIR} ${WRKINST}${CHROOT_DIR}/etc
	${INSTALL_DATA_DIR} ${PREFIX}/share/s4a/detectors
	${INSTALL_DATA} ${WRKBUILD}/conf/s4a.sample/* ${WRKINST}${CHROOT_DIR}/conf/s4a.sample
	${INSTALL_DATA} ${WRKBUILD}/confserv/* ${WRKINST}${CHROOT_DIR}/confserv
	${INSTALL_DATA} ${WRKBUILD}/database/* ${WRKINST}${CHROOT_DIR}/database
	${INSTALL_SCRIPT} ${WRKBUILD}/database/*.sh ${WRKINST}${CHROOT_DIR}/database
	${INSTALL_SCRIPT} ${WRKBUILD}/database/update_db.php ${WRKINST}${CHROOT_DIR}/database
	${INSTALL_DATA} ${WRKBUILD}/keygen/* ${PREFIX}/s4a-centre/keygen
	${INSTALL_SCRIPT} ${WRKBUILD}/keygen/*.sh ${PREFIX}/s4a-centre/keygen
	${INSTALL_SCRIPT} ${WRKBUILD}/sigsupporter/* ${PREFIX}/s4a-centre/sigsupporter
	${INSTALL_DATA} ${WRKBUILD}/s4a-view/*.png ${WRKINST}${CHROOT_DIR}/s4a-view
	${INSTALL_DATA} ${WRKBUILD}/s4a-view/*.css ${WRKINST}${CHROOT_DIR}/s4a-view
	${INSTALL_DATA} ${WRKBUILD}/s4a-view/*.php ${WRKINST}${CHROOT_DIR}/s4a-view
	${INSTALL_DATA} ${WRKBUILD}/s4a-view/*.html ${WRKINST}${CHROOT_DIR}/s4a-view
	${INSTALL_DATA} ${WRKBUILD}/s4a-view/images/* ${WRKINST}${CHROOT_DIR}/s4a-view/images
	${INSTALL_PROGRAM} ${WRKBUILD}/s4ad/s4ad ${PREFIX}/bin/s4ad
	${INSTALL_PROGRAM} ${WRKBUILD}/s4a-draw/s4a-draw ${PREFIX}/bin/s4a-draw
	${INSTALL_MAN} ${WRKBUILD}/man/s4a-centre.0 ${PREFIX}/man/cat8/s4a-centre.0
	${INSTALL_MAN} ${WRKBUILD}/man/s4a-centre.0 ${PREFIX}/man/cat8/s4a-sig-current.0
	${INSTALL_MAN} ${WRKBUILD}/man/s4a-centre.0 ${PREFIX}/man/cat8/s4a-sig-check-current.0
	${INSTALL_MAN} ${WRKBUILD}/man/s4a-centre.0 ${PREFIX}/man/cat8/s4a-sig-check.0
	${INSTALL_MAN} ${WRKBUILD}/man/s4a-centre.0 ${PREFIX}/man/cat8/s4a-sig-apply.0
	${INSTALL_MAN} ${WRKBUILD}/man/s4a-centre.0 ${PREFIX}/man/cat8/s4a-sig-revoke.0


.include <bsd.port.mk>
