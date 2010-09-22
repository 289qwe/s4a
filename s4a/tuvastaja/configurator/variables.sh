#!/bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

#This file is for variables

TERM=xterm-color
USB="[USB]"

TITLE="Tuvastaja konfigureerimine"
MAINMENU="Konfigureerimismen��"
ITEM1="V�rgus�tted"
ITEM2="Meilis�tted"
ITEM3="Konfiguratsiooni taastamine varukoopiast $USB"
ITEM4="Keskserveri v�tmete haldus"
ITEM5="Sekundaarse keskserveri v�tmete haldus"
ITEM6="Ajaserveri s�tted"
ITEM7="V�lise seires�steemi s�tted"
ITEM8="Snorti ja IPAuditi s�tted"
ITEM9="S�steemse logi s�tted"
ITEM10="Paroolide haldamine"
ITEM11="N�ita k�iki konfigureeritud s�tteid"
ITEM12="Konfiguratsiooni varundamine $USB"
ITEM13="Andmete h�vitamine"
ITEM14="Arhiveeri s�tted ja sulge konfigureerija"
BACK="Tagasi"

IP1="V�rguliideste (haldus- ja Snorti liideste) valik"
IP2="IP-aadress"
IP3="V�rgumask"
IP4="V�rgul��s"
IP5="Hostinimi"
IP6="Domeeninimi"
IP7="Nimeserver"
IP8="N�ita v�rgus�tteid"
IP9="Rakenda s�tted"
IP10="Peamen��sse"
PREBOOT="Sulge konfigureerija"
ETH="Haldusliidese valik"
TRUNK="Snorti liideste valik"

EMAIL="Meilisaatmise seadistamine"
EMAIL1="Administraatori meiliaadress"
EMAIL2="SMTP vahendaja hostinimi v�i aadress"
EMAIL3="Postita s�tted administraatorile"
EMAILMSG="See kiri saadeti l�bi meiliserveri"
EMAILPARAMS="parameetrid seisuga"
EMAILSENT="Meil saadetud aadressile:"
IFEMAIL="Kas suunata kirjad administraatori meiliaadressile?"

PASS1="Vaheta administraatori konto (admin) parool"
PASS2="Vaheta juurkasutaja konto (root) parool"
PASS3="Vaheta veebiliidese kasutaja (webadmin) parool"

PRE1="$ITEM1"
PRE2="Konfiguratsiooni, v�tmete ja sertifikaatide taastamine $USB"

FAILIP="Aadress peab olema kujul 0-255.0-255.0-255.0-255"
FAILIPDEV="Viga: Liiga palju v�i mitte �htegi v�rguliidest. Leitud liidesed on"
FAILTRUNKDEV="Ei leitud teisi liideseid peale haldusliidese, kuulan liidesel 'localhost'"
FAILEMAIL="Aadress peab sisaldama '@' ja korrektset domeeninime"
FAILDOMAIN="Vales vormingus domeeninimi"
FAILTEXT="Vigane v��rtus"
FAILCIDR="Aadressid peavad olema CIDR-kujul"
MAKEFAIL="Konfigureerimine nurjus."
BACKUPFAIL="S�tete arhiveerimine nurjus.\nKonfiguratsioon on poolik -- tuvastaja ei pruugi t��tada!\n"
BACKUPWARNFAIL="S�tted arhiveeriti, kuid\nkonfiguratsioon on poolik -- tuvastaja ei pruugi t��tada!\n"
VARNOTSET="Konfigureerimata on"
MAILFAIL="Meili saatmine nurjus."

NTP="Ajaserveri aadress"
SNMP="V�lise seires�steemi aadress"
SNMPCOMMUNITY="V�lise seires�steemi 'community' nimi"
SNORT="Lokaalsed v�rgud CIDR-kujul"
SYSLOG="V�lise syslog-serveri IP-aadress"

SNMP1="Kas soovid kasutada v�list seires�steemi?"
SYSLOG1="Kas soovid logi suunata v�lisele syslog-serverile?"
NOSYSLOG="m��ramata"

SECONDCERTCHOICE="Kas soovid hallata sekundaarse keskserveri v�tmeid?"
DELETESECONDCERTS="Kustutan k�ik sekundaarse keskserveri v�tmed ja sertifikaadid"
DELETECERTSWARNING="HOIATUS! J�TKAMISEL KATKESTATAKSE �HENDUSED SEKUNDAARSELE KESKSERVERILE!\n\
�HENDUSED POLE TAASTATAVAD, KUI V�TMEID JA SERTIFIKAATE POLE VARUNDATUD!\nKAS T�ESTI J�TKATA?"

SHOWMSG="Konfigureeritud v�rguv��rtused, mis ei pruugi olla rakendatud s�tted.\nRakendamiseks vali $ITEM1 men��st $IP9."
SHOWALL="Konfigureeritud Tuvastaja v��rtused, mis ei pruugi olla rakendatud s�tted.\nRakendamiseks vali vastavatest men��dest $IP9."
SHOWINFO="T�hjad s�tted osutavad, et vastav punkt on seadistamata.\nKui sertifikaadist tulevad andmed pole v��rtustatud,\n\
siis on v�tmed laadimata.\nNB! Tarkvara versioon m��ratakse esimest korda alles\ns�tete arhiveerimisel."
YES="Jah"
NO="Ei"

KEY1="Genereeri sertifitseerimistaotlus $USB"
KEY2="Keskserveri v�tmete laadimine $USB"
KEY1ASK="Organisatsiooni nimi"
KEYBACKUP="V�tmete ja sertifikaatide varundamine $USB"
KEYRESTORE="V�tmete ja sertifikaatide taastamine $USB"

PRIMCENTRALRESTORE="Keskserveri v�tmete ja sertifikaatide taastamine $USB"
SECCENTRALRESTORE="Sekundaarse keskserveri v�tmete ja sertifikaatide taastamine $USB"

CERT1="Tuvastaja l�hinimi sertifikaadist"
CERT2="Tuvastaja t�isnimi sertifikaadist"
CERT3="Tuvastaja organisatsioon sertifikaadist"
CERT4="Keskserveri aadress sertifikaadist"
CERT5="Sekundaarse keskserveri aadress sertifikaadist"
VERSION="Tuvastaja tarkvara versiooninumber"

DETECTORKEY="Tuvastaja salajane v�ti"
DETECTORCERT="Tuvastaja sertifikaat"
CACERT="CA-sertifikaat"
PASSDIFF="Sisestatud paroolid olid erinevad?"
WRONGPASS="Vale parool?"
NOCERTBACKUPFILE="Tagavarafaili ei leitud USB-seadme juurkataloogist."

DESTROY1="Kustutan andmepartitsiooni nime (\"puhta\" paigalduse jaoks)"
DESTROY2="H�vitan kogu k�vaketta sisu"

MOUNTFAIL="Tekkisid probleemid USB-seadme k�lgehaakimisel. Seadet pole veel arvuti k�ljes?"
UMOUNTFAIL="Tekkisid probleemid USB-seadme lahtihaakimisel. Seadet pole enam arvuti k�ljes?"
UMOUNTDATA="Tekkisid probleemid andmepartitsiooni lahtihaakimisel.\nProovi uuesti!"
REMOUNTROOT="Tekkisid probleemid juurpartitsiooni �mberhaakimisel"
MOUNTSUCC="Konfiguratsioon on USB-seadmelt taastatud."
BACKUPSUCC="Konfiguratsioon on USB-seadmele varundatud."
RESTOREFAIL="Konfiguratsioonifaili USB-seadmelt ei leitud."
KEYSUCC="V�tmed on USB-seadmelt laaditud"
REQSUCC="Sertifitseerimisp�ring on USB-seadmele laaditud"
KEYCERTFAIL="Faili tuvastaja.tgz ei leitud USB-seadme juurkataloogist."
CERTRESTOREFAIL="V�tmete ja sertifikaatide taastamine nurjus"
CERTRESTORESUCC="V�tmed ja sertifikaadid on USB-seadmelt taastatud"
CERTBACKUPFAIL="V�tmete ja sertifikaatide varundamine nurjus"
CERTBACKUPSUCC="V�tmed ja sertifikaadid on USB-seadmele varundatud"
NOCERTFILE="Puudu on"
NOPATCHCERT="Paikamise sertifikaati ei leitud.\nPaikade verifitseerimine ei �nnestu."
KEYCERTDIFF="$DETECTORKEY ja $DETECTORCERT ei ole omavahel �hilduvad"
SUGGESTNEWREQ="V�imalusel taastada sertifikaadid varukoopiast men�� \"$KEYRESTORE\" kaudu v�i tekitada uus p�ring men�� \"$KEY1\" kaudu"
KEYOVERWRITE="HOIATUS! $DETECTORKEY on juba olemas!\nJ�tkamisel tekitatakse uus p�ring ning kirjutatakse kehtiv v�ti �le\nKAS T�ESTI J�TKATA?"

TRUNKFAIL="Viga Snorti liideste valimisel. �htegi liidest pole valitud?"
WAIT="V�ib kuluda m�ni sekund, mil ekraanil ei n�idata midagi, oota..."
NOHOSTDOM="Tuvastaja hostinimi ja/v�i domeeninimi on seadistamata. V�ljun!"

SNORTEMPTY="Andmeid pole veel kogutud, kontrollimiseks v&auml;rskenda lehte (F5)"
CLEARWARN="HOIATUS! J�TKAMISEL KOGU K�VAKETAS (ka andmepartitsioon) T�HJENDATAKSE!\n\
KAS T�ESTI J�TKATA?"
CLEAR="H�vitan k�vakettalt andmeid.\nSelleks v�ib kuluda kuni 24 tundi (h�vitamiskiirusel 1.5 MB/sec).\n\
L�puks v�ib ilmneda 'kernel panic'.\nSee t�hendab, et kogu k�vaketas on t�hi\nning arvuti tuleb Power nupust v�lja l�litada."
CLEARDATA="Kirjutan andmepartitsiooni nime �le.\nSelle valmides v�ib ilmneda 'kernel panic'.\n\
See t�hendab, et operatsioon �nnestus\nning arvuti tuleb Power nupust v�lja l�litada.\n\n\
Arvutile saab teha siis \"puhta\" paigalduse."
EMPTY="K�vaketas on t�hi; l�lita arvuti Power nupust v�lja"

NTPASK="$NTP\nkujul aja.server.ee v�i 192.168.1.1"
SNORTASK="$SNORT\ntavaliselt 192.168.0.0/16 v�i 10.0.0.0/8"
SYSLOGASK="$SYSLOG\nkujul 192.168.1.1"
EMAIL2ASK="$EMAIL2\nkujul meiliserver.asutus.ee v�i 192.168.1.1"
EMAIL1ASK="$EMAIL1\nkujul administraator@meiliserver.ee"
IP2ASK="$IP2\nkujul 192.168.1.1"
IP3ASK="$IP3\nn�iteks 255.255.255.0"
IP4ASK="$IP4\nkujul 192.168.1.1"
IP5ASK="$IP5\nkujul 'arvutinimi'"
IP6ASK="$IP6\nkujul 'asutus.ee' v�i 'sisemine'"
IP7ASK="$IP7\nkujul 192.168.1.1"
SNMPASK="$SNMP\nkujul 192.168.1.1"
SNMPCOMMUNITYASK="$SNMPCOMMUNITY\nn�iteks 'tuvastaja'"

MAINNET="Haldus"
MONITORNET="Monitor"
