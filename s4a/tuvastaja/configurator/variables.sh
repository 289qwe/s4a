#!/bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

#This file is for variables

TERM=xterm-color
USB="[USB]"

TITLE="Tuvastaja konfigureerimine"
MAINMENU="Konfigureerimismenüü"
ITEM1="Võrgusätted"
ITEM2="Meilisätted"
ITEM3="Konfiguratsiooni taastamine varukoopiast $USB"
ITEM4="Keskserveri võtmete haldus"
ITEM5="Sekundaarse keskserveri võtmete haldus"
ITEM6="Ajaserveri sätted"
ITEM7="Välise seiresüsteemi sätted"
ITEM8="Snorti ja IPAuditi sätted"
ITEM9="Süsteemse logi sätted"
ITEM10="Paroolide haldamine"
ITEM11="Näita kõiki konfigureeritud sätteid"
ITEM12="Konfiguratsiooni varundamine $USB"
ITEM13="Andmete hävitamine"
ITEM14="Arhiveeri sätted ja sulge konfigureerija"
BACK="Tagasi"

IP1="Võrguliideste (haldus- ja Snorti liideste) valik"
IP2="IP-aadress"
IP3="Võrgumask"
IP4="Võrgulüüs"
IP5="Hostinimi"
IP6="Domeeninimi"
IP7="Nimeserver"
IP8="Näita võrgusätteid"
IP9="Rakenda sätted"
IP10="Peamenüüsse"
PREBOOT="Sulge konfigureerija"
ETH="Haldusliidese valik"
TRUNK="Snorti liideste valik"

EMAIL="Meilisaatmise seadistamine"
EMAIL1="Administraatori meiliaadress"
EMAIL2="SMTP vahendaja hostinimi või aadress"
EMAIL3="Postita sätted administraatorile"
EMAILMSG="See kiri saadeti läbi meiliserveri"
EMAILPARAMS="parameetrid seisuga"
EMAILSENT="Meil saadetud aadressile:"
IFEMAIL="Kas suunata kirjad administraatori meiliaadressile?"

PASS1="Vaheta administraatori konto (admin) parool"
PASS2="Vaheta juurkasutaja konto (root) parool"
PASS3="Vaheta veebiliidese kasutaja (webadmin) parool"

PRE1="$ITEM1"
PRE2="Konfiguratsiooni, võtmete ja sertifikaatide taastamine $USB"

FAILIP="Aadress peab olema kujul 0-255.0-255.0-255.0-255"
FAILIPDEV="Viga: Liiga palju või mitte ühtegi võrguliidest. Leitud liidesed on"
FAILTRUNKDEV="Ei leitud teisi liideseid peale haldusliidese, kuulan liidesel 'localhost'"
FAILEMAIL="Aadress peab sisaldama '@' ja korrektset domeeninime"
FAILDOMAIN="Vales vormingus domeeninimi"
FAILTEXT="Vigane väärtus"
FAILCIDR="Aadressid peavad olema CIDR-kujul"
MAKEFAIL="Konfigureerimine nurjus."
BACKUPFAIL="Sätete arhiveerimine nurjus.\nKonfiguratsioon on poolik -- tuvastaja ei pruugi töötada!\n"
BACKUPWARNFAIL="Sätted arhiveeriti, kuid\nkonfiguratsioon on poolik -- tuvastaja ei pruugi töötada!\n"
VARNOTSET="Konfigureerimata on"
MAILFAIL="Meili saatmine nurjus."

NTP="Ajaserveri aadress"
SNMP="Välise seiresüsteemi aadress"
SNMPCOMMUNITY="Välise seiresüsteemi 'community' nimi"
SNORT="Lokaalsed võrgud CIDR-kujul"
SYSLOG="Välise syslog-serveri IP-aadress"

SNMP1="Kas soovid kasutada välist seiresüsteemi?"
SYSLOG1="Kas soovid logi suunata välisele syslog-serverile?"
NOSYSLOG="määramata"

SECONDCERTCHOICE="Kas soovid hallata sekundaarse keskserveri võtmeid?"
DELETESECONDCERTS="Kustutan kõik sekundaarse keskserveri võtmed ja sertifikaadid"
DELETECERTSWARNING="HOIATUS! JÄTKAMISEL KATKESTATAKSE ÜHENDUSED SEKUNDAARSELE KESKSERVERILE!\n\
ÜHENDUSED POLE TAASTATAVAD, KUI VÕTMEID JA SERTIFIKAATE POLE VARUNDATUD!\nKAS TÕESTI JÄTKATA?"

SHOWMSG="Konfigureeritud võrguväärtused, mis ei pruugi olla rakendatud sätted.\nRakendamiseks vali $ITEM1 menüüst $IP9."
SHOWALL="Konfigureeritud Tuvastaja väärtused, mis ei pruugi olla rakendatud sätted.\nRakendamiseks vali vastavatest menüüdest $IP9."
SHOWINFO="Tühjad sätted osutavad, et vastav punkt on seadistamata.\nKui sertifikaadist tulevad andmed pole väärtustatud,\n\
siis on võtmed laadimata.\nNB! Tarkvara versioon määratakse esimest korda alles\nsätete arhiveerimisel."
YES="Jah"
NO="Ei"

KEY1="Genereeri sertifitseerimistaotlus $USB"
KEY2="Keskserveri võtmete laadimine $USB"
KEY1ASK="Organisatsiooni nimi"
KEYBACKUP="Võtmete ja sertifikaatide varundamine $USB"
KEYRESTORE="Võtmete ja sertifikaatide taastamine $USB"

PRIMCENTRALRESTORE="Keskserveri võtmete ja sertifikaatide taastamine $USB"
SECCENTRALRESTORE="Sekundaarse keskserveri võtmete ja sertifikaatide taastamine $USB"

CERT1="Tuvastaja lühinimi sertifikaadist"
CERT2="Tuvastaja täisnimi sertifikaadist"
CERT3="Tuvastaja organisatsioon sertifikaadist"
CERT4="Keskserveri aadress sertifikaadist"
CERT5="Sekundaarse keskserveri aadress sertifikaadist"
VERSION="Tuvastaja tarkvara versiooninumber"

DETECTORKEY="Tuvastaja salajane võti"
DETECTORCERT="Tuvastaja sertifikaat"
CACERT="CA-sertifikaat"
PASSDIFF="Sisestatud paroolid olid erinevad?"
WRONGPASS="Vale parool?"
NOCERTBACKUPFILE="Tagavarafaili ei leitud USB-seadme juurkataloogist."

DESTROY1="Kustutan andmepartitsiooni nime (\"puhta\" paigalduse jaoks)"
DESTROY2="Hävitan kogu kõvaketta sisu"

MOUNTFAIL="Tekkisid probleemid USB-seadme külgehaakimisel. Seadet pole veel arvuti küljes?"
UMOUNTFAIL="Tekkisid probleemid USB-seadme lahtihaakimisel. Seadet pole enam arvuti küljes?"
UMOUNTDATA="Tekkisid probleemid andmepartitsiooni lahtihaakimisel.\nProovi uuesti!"
REMOUNTROOT="Tekkisid probleemid juurpartitsiooni ümberhaakimisel"
MOUNTSUCC="Konfiguratsioon on USB-seadmelt taastatud."
BACKUPSUCC="Konfiguratsioon on USB-seadmele varundatud."
RESTOREFAIL="Konfiguratsioonifaili USB-seadmelt ei leitud."
KEYSUCC="Võtmed on USB-seadmelt laaditud"
REQSUCC="Sertifitseerimispäring on USB-seadmele laaditud"
KEYCERTFAIL="Faili tuvastaja.tgz ei leitud USB-seadme juurkataloogist."
CERTRESTOREFAIL="Võtmete ja sertifikaatide taastamine nurjus"
CERTRESTORESUCC="Võtmed ja sertifikaadid on USB-seadmelt taastatud"
CERTBACKUPFAIL="Võtmete ja sertifikaatide varundamine nurjus"
CERTBACKUPSUCC="Võtmed ja sertifikaadid on USB-seadmele varundatud"
NOCERTFILE="Puudu on"
NOPATCHCERT="Paikamise sertifikaati ei leitud.\nPaikade verifitseerimine ei õnnestu."
KEYCERTDIFF="$DETECTORKEY ja $DETECTORCERT ei ole omavahel ühilduvad"
SUGGESTNEWREQ="Võimalusel taastada sertifikaadid varukoopiast menüü \"$KEYRESTORE\" kaudu või tekitada uus päring menüü \"$KEY1\" kaudu"
KEYOVERWRITE="HOIATUS! $DETECTORKEY on juba olemas!\nJätkamisel tekitatakse uus päring ning kirjutatakse kehtiv võti üle\nKAS TÕESTI JÄTKATA?"

TRUNKFAIL="Viga Snorti liideste valimisel. Ühtegi liidest pole valitud?"
WAIT="Võib kuluda mõni sekund, mil ekraanil ei näidata midagi, oota..."
NOHOSTDOM="Tuvastaja hostinimi ja/või domeeninimi on seadistamata. Väljun!"

SNORTEMPTY="Andmeid pole veel kogutud, kontrollimiseks v&auml;rskenda lehte (F5)"
CLEARWARN="HOIATUS! JÄTKAMISEL KOGU KÕVAKETAS (ka andmepartitsioon) TÜHJENDATAKSE!\n\
KAS TÕESTI JÄTKATA?"
CLEAR="Hävitan kõvakettalt andmeid.\nSelleks võib kuluda kuni 24 tundi (hävitamiskiirusel 1.5 MB/sec).\n\
Lõpuks võib ilmneda 'kernel panic'.\nSee tähendab, et kogu kõvaketas on tühi\nning arvuti tuleb Power nupust välja lülitada."
CLEARDATA="Kirjutan andmepartitsiooni nime üle.\nSelle valmides võib ilmneda 'kernel panic'.\n\
See tähendab, et operatsioon õnnestus\nning arvuti tuleb Power nupust välja lülitada.\n\n\
Arvutile saab teha siis \"puhta\" paigalduse."
EMPTY="Kõvaketas on tühi; lülita arvuti Power nupust välja"

NTPASK="$NTP\nkujul aja.server.ee või 192.168.1.1"
SNORTASK="$SNORT\ntavaliselt 192.168.0.0/16 või 10.0.0.0/8"
SYSLOGASK="$SYSLOG\nkujul 192.168.1.1"
EMAIL2ASK="$EMAIL2\nkujul meiliserver.asutus.ee või 192.168.1.1"
EMAIL1ASK="$EMAIL1\nkujul administraator@meiliserver.ee"
IP2ASK="$IP2\nkujul 192.168.1.1"
IP3ASK="$IP3\nnäiteks 255.255.255.0"
IP4ASK="$IP4\nkujul 192.168.1.1"
IP5ASK="$IP5\nkujul 'arvutinimi'"
IP6ASK="$IP6\nkujul 'asutus.ee' või 'sisemine'"
IP7ASK="$IP7\nkujul 192.168.1.1"
SNMPASK="$SNMP\nkujul 192.168.1.1"
SNMPCOMMUNITYASK="$SNMPCOMMUNITY\nnäiteks 'tuvastaja'"

MAINNET="Haldus"
MONITORNET="Monitor"
