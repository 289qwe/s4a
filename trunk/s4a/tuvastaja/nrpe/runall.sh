#!/bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */


#NOSSL="-n"
NOSSL=""

/bin/check_nrpe $NOSSL -p 5666 -H 127.0.0.1 -c check_cert
/bin/check_nrpe $NOSSL -p 5666 -H  127.0.0.1 -c check_root
/bin/check_nrpe $NOSSL -p 5666 -H  127.0.0.1 -c check_data
/bin/check_nrpe $NOSSL -p 5666 -H  127.0.0.1 -c check_ratio
/bin/check_nrpe $NOSSL -p 5666 -H  127.0.0.1 -c check_snort
/bin/check_nrpe $NOSSL -p 5666 -H  127.0.0.1 -c check_cpu
/bin/check_nrpe $NOSSL -p 5666 -H  127.0.0.1 -c check_sigcounter
/bin/check_nrpe $NOSSL -p 5666 -H  127.0.0.1 -c check_ipcounter
/bin/check_nrpe $NOSSL -p 5666 -H  127.0.0.1 -c check_dns
/bin/check_nrpe $NOSSL -p 5666 -H  127.0.0.1 -c check_ntp
/bin/check_nrpe $NOSSL -p 5666 -H 127.0.0.1 -c check_updater

exit 0
