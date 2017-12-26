#!/bin/bash

BASE_DIR="/opt/deb"
SOURCE_DIR="/opt/dnsperf-src/dnsperf"

# Search the actual version number in source file
version_majeur=$(grep 'VERSION "' ${SOURCE_DIR}/version.h|awk '{print $3}'|sed 's/"//g')

# année mois jour heure
#version_mineur=$(date +%Y%m%d.%H)
version_mineur=1
#
version_arch=$(dpkg --print-architecture)
#
VERSION="dnsperf-${version_majeur}-${version_mineur}_${version_arch}"

# Si le répertoire existe déjà on supprime
# If directory exist, will be delete it
if [ -d ${BASE_DIR}/$VERSION/ ]
then
    echo "Le répertoire existe déjà, on le supprime"
    rm -rf ${BASE_DIR}/$VERSION/
fi

# Création des répertoires
mkdir -p ${BASE_DIR}/$VERSION/DEBIAN
# binary dir
mkdir -p ${BASE_DIR}/$VERSION/usr/bin
# man dir
mkdir -p ${BASE_DIR}/$VERSION/usr/share/man/man1/
# doc dir
mkdir -p ${BASE_DIR}/$VERSION/usr/share/doc/dnsperf

# Copyright file
cat << EOF > ${BASE_DIR}/$VERSION/usr/share/doc/dnsperf/copyright
This is the Debian GNU/Linux prepackaged version of dnsperf

dnsperf - DNS Performance Testing Tools - Apache License Version 2.0

This package is maintained for Debian by Alban VIDAL <alban.vidal@zordhak.fr>,
and was built from the sources found at:

    https://github.com/nominum/dnsperf

Official website of nominum:

    https://www.nominum.com/
    https://www.nominum.com/measurement-tools/

On Debian GNU/Linux systems, the complete text of the Apache License
Version 2.0 can be found in /usr/share/common-licenses/Apache-2.0.

The Debian packaging is

    Copyright (C) 2017 Alban VIDAL <alban.vidal@zordhak.fr>.
EOF

# Changelog file
cat << EOF > ${BASE_DIR}/$VERSION/usr/share/doc/dnsperf/changelog
dnsperf (2.1.1.0.d-1) stretch; urgency=low

  * Initial Release of Debian package for dnsperf

 -- Alban Vidal <alban.vidal@zordhak.fr>  $(LANG=en_US date "+%a, %d %b %Y %R:%S %z")
EOF
# compress changelog file
gzip --best --no-name ${BASE_DIR}/$VERSION/usr/share/doc/dnsperf/changelog

################################################################################
# Copie des fichiers
cd $SOURCE_DIR
/usr/bin/install -c  dnsperf ${BASE_DIR}/$VERSION/usr/bin
/usr/bin/install -c  resperf ${BASE_DIR}/$VERSION/usr/bin
/usr/bin/install -c  resperf-report ${BASE_DIR}/$VERSION/usr/bin
/usr/bin/install -c -m 644  dnsperf.1 ${BASE_DIR}/$VERSION/usr/share/man/man1
/usr/bin/install -c -m 644  resperf.1 ${BASE_DIR}/$VERSION/usr/share/man/man1
# Create symbolic link for resperf-report to resperf
ln -s resperf.1.gz ${BASE_DIR}/$VERSION/usr/share/man/man1/resperf-report.1.gz
# Compress manpages
# --best => best compression (level 9)
# --no-name => to supress package-contains-timestamped-gzip
gzip --best --no-name ${BASE_DIR}/$VERSION/usr/share/man/man1/dnsperf.1
gzip --best --no-name ${BASE_DIR}/$VERSION/usr/share/man/man1/resperf.1

# Generate md5sum for each file
cd ${BASE_DIR}/$VERSION/
find . -type f ! -regex '.*.hg.*' ! -regex '.*?debian-binary.*' ! -regex '.*?DEBIAN.*' -printf '%P ' | xargs md5sum > DEBIAN/md5sums

# Calcul Installed-Size - see https://www.debian.org/doc/debian-policy/#s-f-installed-size
totalSize=$(du -s --exclude=DEBIAN ${BASE_DIR}/$VERSION|awk '{print $1}')
installedSize=$(( totalSize / 1024 ))
(( installedSize ++ ))

# Debian control
cat << EOF > ${BASE_DIR}/$VERSION/DEBIAN/control
Package: dnsperf
Version: $version_majeur-$version_mineur
Section: admin
Priority: optional
Architecture: $version_arch
Installed-Size: $installedSize
Depends: 
Maintainer: Alban Vidal <alban.vidal@zordhak.fr>
Homepage: https://github.com/nominum/dnsperf
Description: DNS Performance Testing Tools
 This is a collection of DNS server performance testing tools, including
 dnsperf and resperf. For more information, see the dnsperf(1) and resperf(1)
 man pages.
 .
 Usage:
 dnsperf and resperf read input files describing DNS queries, and send those
 queries to DNS servers to measure performance.
EOF



################################################################################
# Création du fichier .deb
cd ${BASE_DIR}
dpkg-deb --build $VERSION

