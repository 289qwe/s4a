#!/bin/sh

# /* Copyright (C) 2011, Cybernetica AS, http://www.cybernetica.eu/ */


#this file is for calling values from defined variables file

IFACE="IFACE.var"
IPADDR="IP_address.var"
SUBMASK="Subnet_mask.var"
GATEWAY="Default_Gateway.var"
HOSTNAME="Hostname.var"
DOMAIN="Domain.var"
DNS="NameServers.var"
NTPADDR="NTP_server.var"
SMTPADDR="SMTP.var"
ADMINMAIL="Admin_Email.var"
SNMPADDR="SNMP_server.var"
LOCALNETS="Localnets.var"
TRUNKIFACES="Trunkifaces.var"
SYSLOGSERVER="Syslogserver.var"
SOFTVER="Software_Version.var"
#ROCOMMUNITY="Ro_community.var"
CENTRAL="Centralserver.var"
SHORTNAME="Shortname.var"
LONGNAME="Fullname.var"
ORG="Organisation.var"
SECONDCENTRAL="Second_central.var"
LOCALORG="Localorg.var"
SERIALNUMBER="Serial.var"

CANAME="cacert.crt"
DETNAME="tuvastaja.crt"
PATCHNAME="s4apatch.pem"
KEYNAME="tuvastaja.key"

VAR_IFACE=$VARDIR/$IFACE
VAR_IP_ADDRESS=$VARDIR/$IPADDR
VAR_SUBNET_MASK=$VARDIR/$SUBMASK
VAR_DEFAULT_GATEWAY=$VARDIR/$GATEWAY
VAR_HOSTNAME=$VARDIR/$HOSTNAME
VAR_DOMAIN=$VARDIR/$DOMAIN
VAR_NAMESERVERS=$VARDIR/$DNS
VAR_NTP_SERVER=$VARDIR/$NTPADDR
VAR_SMTP=$VARDIR/$SMTPADDR
VAR_ADMIN_EMAIL=$VARDIR/$ADMINMAIL
VAR_SNMP_SERVER=$VARDIR/$SNMPADDR
VAR_LOCALNETS=$VARDIR/$LOCALNETS
VAR_TRUNKIFACES=$VARDIR/$TRUNKIFACES
VAR_SYSLOGSERVER=$VARDIR/$SYSLOGSERVER
VAR_SOFTWARE_VERSION=$VARDIR/$SOFTVER
#VAR_RO_COMMUNITY=$VARDIR/$ROCOMMUNITY
VAR_CENTRALSERVER=$VARDIR/$CENTRAL
VAR_SHORTNAME=$VARDIR/$SHORTNAME
VAR_FULLNAME=$VARDIR/$LONGNAME
VAR_ORGANISATION=$VARDIR/$ORG
VAR_SECONDCENTRAL=$VARDIR/$SECONDCENTRAL
VAR_LOCALORG=$VARDIR/$LOCALORG
VAR_SERIALNUMBER=$VARDIR/$SERIALNUMBER

VARIABLES="$VAR_IFACE $VAR_IP_ADDRESS $VAR_SUBNET_MASK $VAR_DEFAULT_GATEWAY $VAR_HOSTNAME \
$VAR_DOMAIN $VAR_NAMESERVERS $VAR_ADMIN_EMAIL $VAR_SMTP $VAR_NTP_SERVER $VAR_SNMP_SERVER \
$VAR_LOCALNETS $VAR_TRUNKIFACES $VAR_SYSLOGSERVER"
