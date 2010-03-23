#!/bin/sh

# Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/


URL=ftp://ftp.estpak.ee/pub/OpenBSD/4.6/packages/i386/
CYBER=http://ondatra.cyber.ee/~mattu/tuvastaja/
LIST=`cat index`

for i in $LIST; do
  if [ ! -e $i.tgz ]; then
    wget $CYBER$i.tgz
    if [ $? -ne 0 ]; then
      wget $URL$i.tgz
    fi
  fi
done 
