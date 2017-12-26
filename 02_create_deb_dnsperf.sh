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

# Fichier Debian control
cat << EOF > /opt/deb/$VERSION/DEBIAN/control
Package: dnsperf
Version: $version_majeur-$version_mineur
Section: base
Priority: optional
Architecture: $version_arch
Depends: 
Maintainer: Alban Vidal <alban.vidal@zordhak.fr>
Description: DNS Performance Testing Tools
EOF

################################################################################
# Copie des fichiers
cd /opt/dnsperf-src/dnsperf
/usr/bin/install -c  dnsperf /opt/deb/$VERSION/usr/bin
/usr/bin/install -c  resperf /opt/deb/$VERSION/usr/bin
/usr/bin/install -c  resperf-report /opt/deb/$VERSION/usr/bin
/usr/bin/install -c -m 644  dnsperf.1 /opt/deb/$VERSION/usr/share/man/man1
/usr/bin/install -c -m 644  resperf.1 /opt/deb/$VERSION/usr/share/man/man1

################################################################################
# Création du fichier .deb
cd /opt/deb/
dpkg-deb --build $VERSION

