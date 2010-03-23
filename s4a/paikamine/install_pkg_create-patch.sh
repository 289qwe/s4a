#!/bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

# See skript rakendab pkg_create programmile fixi, mis lisab b64-kodeeritud 
# võtme signeeritavale pakile.
# Skripti käivitamine nõuab juurkasutaja õigusi

if [ ! -s patch-pkg_create ]; then
  echo "pkg_create parandusfail puudub siin kataloogis. Sulgen."
  exit 1
else
  patch -p0 -b /usr/sbin/pkg_create patch-pkg_create
fi
