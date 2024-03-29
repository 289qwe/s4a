#
# Tuvastaja konfiguratsiooni genereerimine
#

# /* Copyright (C) 2011, Cybernetica AS, http://www.cybernetica.eu/ */


VARDIR=/var/www/tuvastaja/data/conf

VAR_IFACE=$(VARDIR)/IFACE.var 
VAR_IP_ADDRESS=$(VARDIR)/IP_address.var 
VAR_SUBNET_MASK=$(VARDIR)/Subnet_mask.var 
VAR_DEFAULT_GATEWAY=$(VARDIR)/Default_Gateway.var 
VAR_HOSTNAME=$(VARDIR)/Hostname.var 
VAR_DOMAIN=$(VARDIR)/Domain.var 
VAR_NAMESERVERS=$(VARDIR)/NameServers.var 
VAR_ADMIN_EMAIL=$(VARDIR)/Admin_Email.var 
VAR_SMTP=$(VARDIR)/SMTP.var 
VAR_NTP_SERVER=$(VARDIR)/NTP_server.var 
VAR_SNMP_SERVER=$(VARDIR)/SNMP_server.var 
#VAR_RO_COMMUNITY=$(VARDIR)/Ro_community.var
VAR_LOCALNETS=$(VARDIR)/Localnets.var 
VAR_TRUNKIFACES=$(VARDIR)/Trunkifaces.var 
VAR_SYSLOGSERVER=$(VARDIR)/Syslogserver.var 
VAR_SOFTWARE_VERSION=$(VARDIR)/Software_Version.var

ROOTMAIL = /etc/mail/aliases
PATCHLEVEL = /var/www/tuvastaja/updater/status/patchlevel

VARIABLES = $(VAR_IFACE) $(VAR_IP_ADDRESS) $(VAR_SUBNET_MASK) $(VAR_DEFAULT_GATEWAY) $(VAR_HOSTNAME) \
	$(VAR_DOMAIN) $(VAR_NAMESERVERS) $(VAR_ADMIN_EMAIL) $(VAR_SMTP) $(VAR_NTP_SERVER) \
	$(VAR_SNMP_SERVER) $(VAR_LOCALNETS) $(VAR_TRUNKIFACES) $(VAR_SYSLOGSERVER)

TARGETS = preboot net email ntp snort monitoring syslog postinst postupd version

all:
	echo "No make all"
	echo "Available targets:  $(TARGETS) "

preboot: simplenet

net: simplenet http pf

simplenet: $(VAR_IFACE) $(VAR_IP_ADDRESS) $(VAR_SUBNET_MASK) $(VAR_HOSTNAME) $(VAR_DOMAIN) \
	$(VAR_TRUNKIFACES) $(VAR_DEFAULT_GATEWAY) $(VAR_NAMESERVERS)
	sh ifdown.sh	
	sh script/gen_network
	sh script/gen_hosts
	sh script/gen_hostname
	sh script/gen_trunkhostname
	sh script/gen_gate
	sh script/gen_resolv	
	sh /etc/netstart

http: $(VAR_HOSTNAME) $(VAR_DOMAIN) 
	sh script/gen_httpd

email: $(ROOTMAIL) smtp

$(ROOTMAIL): $(VAR_ADMIN_EMAIL) 
	sh script/gen_rootmail

smtp: $(VAR_HOSTNAME) $(VAR_DOMAIN) $(VAR_SMTP)
	sh script/gen_smtp
	sh restart_sendmail.sh

ntp: $(VAR_NTP_SERVER)
	sh ntpdown.sh
	sh script/gen_ntpd
	ntpd -s

snort: $(VAR_LOCALNETS) $(VAR_SYSLOGSERVER)
	sh script/gen_snort
	sh script/gen_ipaudit
	sh ../snort/start-stop-snort restart
	sh restart_cron.sh

nrpe: $(VAR_SNMP_SERVER)
	sh nrpedown.sh
	sh script/gen_nrpe
	/usr/local/sbin/nrpe -c /etc/nrpe.cfg -d

pf: $(VAR_IFACE) $(VAR_IP_ADDRESS) $(VAR_TRUNKIFACES)
	sh script/gen_pfconf
	pfctl -f /etc/pf.conf
	
monitoring: nrpe pf

syslog: snort $(VAR_SYSLOGSERVER)
	sh syslogdown.sh
	sh script/gen_syslog
	syslogd -a /var/www/dev/log -a /var/empty/dev/log

$(PATCHLEVEL):
	echo 0 > $(PATCHLEVEL)

$(VAR_SOFTWARE_VERSION): $(PATCHLEVEL)
	sh script/gen_softver

version: $(VAR_SOFTWARE_VERSION)

first:
	sh script/gen_mrtg
	sh script/gen_updatercron
	sh script/gen_motd
	sh script/gen_serialno

initial:
	sh script/gen_snort
	sh script/gen_nrpe
	/usr/local/sbin/nrpe -c /etc/nrpe.cfg -d
	sh script/gen_pfconf
	sh syslogdown.sh
	sh script/gen_syslog
	syslogd -a /var/www/dev/log -a /var/empty/dev/log
	sh script/gen_rootmail
	sh script/gen_smtp
	sh restart_sendmail.sh

postinst: first http initial

postupd: first simplenet email ntp monitoring snort syslog http

$(VARIABLES):
	echo "Required variable $@ is missing"
