# Changes #

## s4a-detector ##
### 4.6.9 ###

  * lsof and traceroute removed from s4a-detector package dependencies
  * installer fixes (detect floppy-disks etc)
  * package category changed to "net"
  * more agressive disk cleanup
  * changes in filenames, folders etc (s4a)

### 4.7.0 ###

  * migrated to OpenBSD 4.7 official release
  * more uniform code-style
  * fixed disk-cleanup usage
  * removed developer specific addresses
  * fixed creating static configuration
  * fixed configuring mail-settings (automatically preset as syslog)
  * improved apache ssl-keys storing
  * nicer crontab lines
  * improved DNS request before loading certificates
  * fixed installing patches (2 or more bsd-packages in one patch)
  * fixed snort behaviour on DST-cases
  * removed unnecessary folders and files from the package
  * fixed mounting USB-device (filters floppies out)
  * improved generating pf.conf
  * improved snort preprocessors configuration
  * improved compromise history in webinterface (checkbox for preprocessors)
  * snort preprocessors information doesn't send to the central server
  * abandoned SNMP, using scripts to collect data
  * net-snmp, nagios-plugins-snmp, libnet removed from s4a-detector package dependencies
  * improved rrd-graphs, more uniform logic
  * '-' is allowd in hostname
  * fixed creating /etc/rc.local
  * improved network devices descriptions
  * improvments installing s4a-detector to the empty OpenBSD machine from package

### 4.7.1 ###

  * more precise diskusage graph script
  * bugfixes in tempfiles and returncodes (snortomatic sends correct codes to the central server)
  * improved hostname regex, based on RFC
  * improved generation of packetfilter configuration: moved to separate target that depends on network parameters changes
  * fixes about reporting expired certificates
  * corrected warning levels about CPU Utilization
  * improved communication of central server where not configured detector doesn't connect to the central server
  * snort general configuration updates
  * OpenBSD 4.7 fixes about using pkg\_add in installing patches
  * developed new graph showing snort drop rate, needs specific snort preprocessor turned on (switched on automatically)
  * improved loading certificates where checked whether key and cert are compatible
  * fixes about snortomatic's waldo file
  * added p5-File-Sync to s4a-detector package dependecy

### 4.7.2 ###

  * added warning-screen to the configurator's Central Server menu when starting generate new certification request if key already exists
  * slight improvements for collecting Snort Drop Rate
  * changed sending Snort running information to the Central Server, now 0-100 (%) has been sent
  * added Snort Drop Rate sending to the Central Server
  * updated to the latest Snort software (2.8.6.1)

### 4.8.0 ###

  * migrated to OpenBSD 4.8 official release
  * fixes in finding disk for data destruction

### 4.9.0 ###

  * migrated to OpenBSD 4.9 official release
  * added detector's serial number collection (DELL) and sending to the Central Server
  * fixed updater.log rotation

### 5.0.0 ###

  * migrated to OpenBSD 5.0 official release, that affected pf, php and network configurations and also disklabel usage
  * bugfixes in snortomatic and install.site

### 5.2.0 ###

  * migrated to OpenBSD 5.2 official release
  * updated to the latest Snort 2.9.3.1 which requires daq 1.1.1 and libdnet 1.12
  * Snort Drop Rate preprocessor (perfmonitor) has to be described considering of chroot that snort runs

## s4a-centre ##
### 4.6.2 ###

  * metaauto, nrpe, p5-proc-processtable and p5-www-curl removed from s4a-centre package dependencies
  * sigsupporter, keygen moved away from apache chroot
  * certificates moved to /etc/ssl, keys to /etc/ssl/private, as common case in OpenBSD.
  * keygen and webreq doesn't overwrite keys/certs, olds would be renamed if exist.
  * removed install\_chroot script
  * changes in filenames, folders etc (s4a)
  * no +x flags anymore on php-files
  * package category changed to "net"

### 4.6.3 ###

  * improved adding detectors to the database: command argument is tgz-archive-file that comes from s4a-ca; added batch-mode capability.
  * fixed sigsupporter module where current sigfile info stores universal file.

### 4.6.4 / 4.7.0 ###

  * improved RRD storage algorithm which is more robust and also infrequent alerts are recorded correctly.
  * fixed graphing algorithm which ensures that low-frequency alerts are not hidden by high-frequency alerts.

### 4.7.1 ###

  * No service with the s4a-detector that has expired certificate
  * removed confserv.log file from s4a-centre package list, admin has to deal with it himself/herself

### 4.7.2 ###

Changes according to new data sent by detectors:
  * fixes storing detectors Snort running information, now 0-100 (%)
  * added storing detectors Snort Drop Rate information in percent, (0-100)
  * added storing detectors Snort rules version in date format.
  * Changes in webinterface based on these changes.

### 4.8.0 ###
  * package for OpenBSD 4.8 official release
  * improved webinterface's snort column behavior for detectors older than 4.7.2

### 4.9.0 ###
  * package for OpenBSD 4.9 official release
  * added storing detectors (DELL) Serial number
  * fixes in xmlrpc code for detectors older than 4.7.2

### 5.0.0 ###
  * package for OpenBSD 5.0 official release

### 5.2.0 ###
  * package for OpenBSD 5.2 official release
  * the environment variable TZ has to be set because of the s4a-centre database php-5.3 commandline scripts.
  * removed lang/php/5.3,-pdo\_sqlite dependency from s4a-centre package because of the sqlite functionality movement to the OpenBSD base.
  * updated s4a-centre manual page

## s4a-ca ##
### 4.6.6 ###

  * bundle.pem file replaced to bundle directory where PEM-encoded certificates can be hold for including them to the detector's or centralserver's certificate-sets.