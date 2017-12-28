#!/bin/bash

# Official webpage :
# https://www.nominum.com/measurement-tools/

# Official github page :
# https://github.com/nominum/dnsperf

################################################################################

# Update and upgrade OS
apt update
apt -y upgrade

# Required : Install nécessary packages and dependencyies to compile dnsperf
apt -y install build-essential bind9utils libbind9-140 bind9 libirs141 libbind-dev libkrb5-dev libcrypto++6 libcap-dev libcrypto++-dev libxml2-dev libssl-dev libgeoip-dev

# purge (delete) old directory
rm -rf /opt/dnsperf-src
# Create source directory and binary directory
mkdir -p /opt/dnsperf-src

cd /opt/dnsperf-src

# Download latest version of dnsperf from official github repository 
git clone https://github.com/nominum/dnsperf.git

cd /opt/dnsperf-src/dnsperf

./configure
# Make binary
make

