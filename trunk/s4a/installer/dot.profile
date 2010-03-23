

# Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/

PATH=/sbin:/bin:/usr/bin:/usr/sbin; export PATH
TERM=vt220; export TERM
umask 022
set -o emacs
echo 'erase ^?, werase ^W, kill ^U, intr ^C, status ^T'
stty newcrt werase ^W intr ^C kill ^U erase ^? status ^T
mount -u /dev/${rootdisk:-rd0a} /

# Network config
ifconfig lo0 inet 127.0.0.1

sh /install || exec sh 
reboot
