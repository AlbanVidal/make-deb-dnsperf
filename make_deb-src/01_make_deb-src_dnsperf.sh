#!/bin/bash

# Update and upgrade OS
apt update
apt -y upgrade

# Required : Install nécessary packages and dependencyies to compile dnsperf
# voir si utile : bind9utils libbind9-140 bind9 libirs141 libcrypto++6 
#apt -y install bind9utils libbind9-140 bind9 libirs141 libbind-dev libkrb5-dev libcrypto++6 libcap-dev libcrypto++-dev libxml2-dev libssl-dev libgeoip-dev
apt -y install libbind-dev libkrb5-dev libcap-dev libcrypto++-dev libxml2-dev libssl-dev libgeoip-dev

# To build debian package
# build-essential
apt -y install devscripts git

################################################################################
####                              EDIT THIS VARS                            ####

TEMPLATE_DIR="${HOME}/make-deb-dnsperf/make_deb-src"

DIR_SRC="/usr/local/src/deb-src/"

################################################################################

# Create destination directory, and to go into
mkdir -p $DIR_SRC
cd $DIR_SRC

# Clone github source repository
git clone https://github.com/nominum/dnsperf.git

# Get version and delete [a-zA-Z] in the end
version=$(grep 'VERSION "' dnsperf/version.h|awk '{print $3}'|sed -e 's/"//g' -e 's/\.[a-zA-Z]$//')

# Rename source directory
mv dnsperf dnsperf-${version}

# Tar source directory
tar caf dnsperf_${version}.orig.tar.gz dnsperf-${version}

# Create debian directory
mkdir dnsperf-${version}/debian

################################################################################
# Copy / Generate debian/xxx files

# Copy debian/changelog
# NOTE: to generate this file
# dch --create -v 2.1.1.0-1 --package dnsperf
cp ${TEMPLATE_DIR}/TEMPLATE_debian_changelog dnsperf-${version}/debian/changelog

# Generate debian/compat
echo 10 > dnsperf-${version}/debian/compat

# Copy debian/control
cp ${TEMPLATE_DIR}/TEMPLATE_debian_control dnsperf-${version}/debian/control

# Copy debian/copyright
cp ${TEMPLATE_DIR}/TEMPLATE_debian_copyright dnsperf-${version}/debian/copyright

# Copy debian/rules
cp ${TEMPLATE_DIR}/TEMPLATE_debian_rules dnsperf-${version}/debian/rules

# Copy debian/dnsperf.dirs
cp ${TEMPLATE_DIR}/TEMPLATE_debian_dnsperf.dirs dnsperf-${version}/debian/dnsperf.dirs

# Copy debian/dnsperf.links
cp ${TEMPLATE_DIR}/TEMPLATE_debian_dnsperf.links dnsperf-${version}/debian/dnsperf.links

# Generate debian/source/format
mkdir dnsperf-${version}/debian/source
echo '3.0 (quilt)' > dnsperf-${version}/debian/source/format

################################################################################
# Generate package
cd dnsperf-${version}
debuild -us -uc


