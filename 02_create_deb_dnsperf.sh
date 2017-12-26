#!/bin/bash

# Search the actual version number in source file
version_majeur=$(grep 'VERSION "' /opt/dnsperf-src/dnsperf/version.h|awk '{print $3}'|sed 's/"//g')

# année mois jour heure
version_mineur=$(date +%Y%m%d.%H)
#
version_arch=$(dpkg --print-architecture)
#
VERSION="dnsperf-${version_majeur}-${version_mineur}-${version_arch}"

# Si le répertoire existe déjà on supprime
# If directory exist, will be delete it
if [ -d /opt/deb/$VERSION/ ]
then
    echo "Le répertoire existe déjà, on le supprime"
    rm -rf /opt/deb/$VERSION/
fi

# Création des répertoires
mkdir -p /opt/deb/$VERSION/DEBIAN
# Création des sous-répertoires
mkdir -p /opt/deb/$VERSION/usr/bin
mkdir -p /opt/deb/$VERSION/usr/share/man/man1/

################################################################################
# Copie des fichiers
cd /opt/dnsperf-src/dnsperf
/usr/bin/install -c  dnsperf /opt/deb/$VERSION/usr/bin
/usr/bin/install -c  resperf /opt/deb/$VERSION/usr/bin
/usr/bin/install -c  resperf-report /opt/deb/$VERSION/usr/bin
/usr/bin/install -c -m 644  dnsperf.1 /opt/deb/$VERSION/usr/share/man/man1
/usr/bin/install -c -m 644  resperf.1 /opt/deb/$VERSION/usr/share/man/man1
# Create symbolic link for resperf-report to resperf
ln -s resperf.1.gz /opt/deb/$VERSION/usr/share/man/man1/resperf-report.1.gz
# Compress manpages
# --best => best compression (level 9)
# --no-name => to supress package-contains-timestamped-gzip
gzip --best --no-name /opt/deb/$VERSION/usr/share/man/man1/dnsperf.1
gzip --best --no-name /opt/deb/$VERSION/usr/share/man/man1/resperf.1

# Generate md5sum for each file

# Calcul Installed-Size - see https://www.debian.org/doc/debian-policy/#s-f-installed-size
totalSize=$(du -s --exclude=DEBIAN /opt/deb/$VERSION|awk '{print $1}')
installedSize=$(( totalSize / 1024 ))
(( installedSize ++ ))

# Debian control
cat << EOF > /opt/deb/$VERSION/DEBIAN/control
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
cd /opt/deb/
dpkg-deb --build $VERSION

