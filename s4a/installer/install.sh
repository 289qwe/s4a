#!/bin/sh

# Copyright (C) 2011, Cybernetica AS, http://www.cybernetica.eu/

MAJ=4			# Version major number
MIN=9			# Version minor number
arch=i386		# Architecture
TZ=Europe/Tallinn	# Time zones are in /usr/share/zoneinfo
SETS="comp man xbase site"
			# comp man misc game x{base,font,serv,share} site
			# bsd{,.rd} base etc selected automatically
CD=cd0
HOSTNAME=tuvastaja
ROOTPW=''		# cfagent will change this to the real cryptstring

# End of user configuration
cat <<EOF

Welcome to the Automated OpenBSD installer.

Nothing has been written to disk yet. If installing OpenBSD is not what
you want, you can still turn off the machine RIGHT NOW pressing Enter
to avoid data loss. If you continue with the following steps, you have
passed the point of no return and all data on this machine is forfeit.

When this script is finished, if it was successful in installing
OpenBSD, the machine will reboot. You will need to configure the BIOS to
boot from the hard disk.

EOF

echo -n "To continue type yes (or sh to start a shell): "
read ANSWER

if [ $ANSWER = yes ]; then
  echo OK
elif [ $ANSWER = sh ]; then
  echo Starting shell
  exit 1
else
  echo Shutting down...
  halt -p
  exit 0
fi
echo Starting installation...

# Find disks
##ALLDRIVES=`sysctl -n hw.disknames | sed -e 's/,/ /g'` 
# Probably in 4.9
ALLDRIVES=`sysctl -n hw.disknames | sed -e 's/:[0-9a-z]\{0,\},\{0,1\}/ /g'` 
# indeed.

# filter out cd* and fd*
NOCD="$ALLDRIVES"
for i in $ALLDRIVES; do
  if echo $i | grep -q "^cd" || echo $i | grep -q "^fd"; then
    NOCD=`echo $NOCD | sed "s/\(.*\)$i\(.*\)/\1\2/"`
  fi
done

DISKDRIVES=""
for i in $NOCD; do
  cd /dev/
  sh MAKEDEV $i
  cd /
  disklabel $i >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    j=""
  else
    if disklabel -h $i | grep label | sed 's/label://' | grep -q "[a-zA-Z0-9]"; then
      j="$i"
    else
      j=""
    fi
  fi
  DISKDRIVES="$DISKDRIVES $j"
done

# Print choices
echo "Available disks are:"
for i in $DISKDRIVES; do
  echo "$i: `disklabel -h $i | grep label | sed 's/label: //'` - `disklabel -h $i | grep 'total bytes' | sed 's/.*total bytes: //'`"
done

# Only one disk
if echo $DISKDRIVES | grep -q "^[a-z][a-z][0-9]$"; then
  # trim spaces
  DISK=`echo $DISKDRIVES`
  echo "Found only one disk: $DISK"
else
  echo "Choose one of the disks above by typing its name (e.g. \"wd0\")"
  diskok=1
  while [ $diskok -ne 0 ]; do
    echo -n "What disk to use for installation? "
    read DISKANSWER
    if ! test -b /dev/"$DISKANSWER"c; then
      echo "No disk /dev/$DISKANSWER"
    else
      echo "You have chosen the following disk: $DISKANSWER"
      DISK=$DISKANSWER
      diskok=0
    fi
  done
fi

echo "Continuing installation to disk: $DISK"

# Check if it's huge enough
SECTORS=`disklabel $DISK | grep "^total sectors:" | sed 's/[a-z: ]*\([0-9]*\)/\1/'`
echo Harddisk consists of $SECTORS sectors.

if [ $SECTORS -lt 25000000 ]; then 
  echo Too small disk. Exiting.
  halt -p
  exit 1
else
  echo Disk is suitable. Continuing.
fi 

# Data important?
echo Checking if data partition exists.
fsck -yf /dev/"$DISK"d > /tmp/fsck

if ! grep "\/var\/www\/tuvastaja\/data" /tmp/fsck; then
echo "Partition doesn't exist. Continuing with clean install."

# Taken from md_prep_fdisk in /usr/src/distrib/i386/common/install.md
fdisk -e $DISK <<EOF
reinit
update
write
quit
EOF

# See md_prep_disklabel in /usr/src/distrib/i386/common/install.md
disklabel -f /tmp/fstab.$DISK -E $DISK <<EOF
z
a b

4g
swap
a a

30%
4.2BSD
/
a d


4.2BSD
/var/www/tuvastaja/data
w
q
EOF
echo "\nYour harddisk is prepared. Creating filesystems.\n"

newfs -q /dev/r${DISK}a
newfs -q /dev/r${DISK}d

else
  newfs -q /dev/r${DISK}a
fi

mount /dev/${DISK}a /mnt
mkdir -p /mnt/{etc,tmp,usr,var,cd}
mkdir -p /mnt/var/www/tuvastaja/data
mount /dev/${CD}a /mnt/cd
mount /dev/${DISK}d /mnt/var/www/tuvastaja/data

# Install files
echo "\nInstalling sets."

for i in bsd bsd.mp; do
  cd /mnt
  cp /mnt/cd/$MAJ.$MIN/$arch/$i .
done
for i in base etc $SETS; do
  tar zxphf /mnt/cd/$MAJ.$MIN/$arch/$i$MAJ$MIN.tgz -C /mnt
done

# SP or MP kernel?
CPU=`sysctl -n hw.ncpufound`
if [ $CPU -gt 1 ]; then
  cp /mnt/bsd /mnt/bsd.sp
  cp /mnt/bsd.mp /mnt/bsd
  echo "Using MP kernel"
else
  echo "Using SP kernel"
fi

echo "Done.\n"

# Localize /etc

cat >/mnt/etc/fstab <<EOF
/dev/${DISK}a / ffs rw,softdep 1 1
/dev/${DISK}b none swap sw 0 0
/dev/${DISK}d /var/www/tuvastaja/data ffs rw,softdep,nodev,nosuid 1 2
EOF

hostname $HOSTNAME
hostname >/mnt/etc/myname

cat >/mnt/etc/hosts <<EOF
::1 localhost
127.0.0.1 localhost
EOF


# See install.sh near the bottom
# I suppose $ROOTPW may contain / but not @

ENCR=`/mnt/usr/bin/encrypt -b 8 -- "$ROOTPW"`
echo "1,s@^root::@root:$ENCR:@
w
q" | /mnt/bin/ed /mnt/etc/master.passwd 2>/dev/null
/mnt/usr/sbin/pwd_mkdb -p -d /mnt/etc /etc/master.passwd

ln -sf /usr/share/zoneinfo/$TZ /mnt/etc/localtime
 
# See finish_up in install.sub
/mnt/sbin/swapctl -a /dev/${DISK}b
( cd /mnt/dev && sh MAKEDEV all )

dd if=/mnt/dev/urandom of=/mnt/var/db/host.random bs=1024 count=64
chmod 600 /mnt/var/db/host.random

# Taken from md_installboot in /usr/src/distrib/i386/common/install.md
cat /usr/mdec/boot >/mnt/boot
/usr/mdec/installboot -v /mnt/boot /usr/mdec/biosboot ${DISK}

test -x /mnt/install.site && /mnt/usr/sbin/chroot /mnt /install.site
rm -f /mnt/install.site

umount /dev/${CD}a
eject /dev/${CD}a

cat <<EOF

Congratulations! you have successfully completed automated OpenBSD$MAJ$MIN
installation. Please remove installation CD from your computer.

EOF

echo -n "Press Enter to reboot"
read KEY
exit 0
