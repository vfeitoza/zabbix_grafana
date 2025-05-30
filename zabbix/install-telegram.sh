#!/bin/bash

INSTALL_PKGS="curl \
    python3 \
    python3-pip \
    snmp \
    snmp-mibs-downloader"

apt-get -y update && \
DEBIAN_FRONTEND=noninteractive apt-get -y \
        --no-install-recommends install \
    ${INSTALL_PKGS} && \
download-mibs && \
sed -i 's/mibs :/# mibs :\nmibs +ALL/g' /etc/snmp/snmp.conf && \
apt-get -y autoremove && \
apt-get -y clean

pip3 install PySocks requests requests-oauthlib --break-system-packages