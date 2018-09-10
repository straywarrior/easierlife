#! /bin/sh -e
#
# fast-setup.sh
# Copyright (C) 2018 StrayWarrior <i@straywarrior.com>
#
# Distributed under terms of the MIT license.
#

OS_TYPE=
LOCALPORT=
REMOTEHOST=
REMORTPORT=

detect_os() {
    if [ -f /etc/redhat-release ]; then
        OS_TYPE="centos"
    fi
    if lsb_release > /dev/null 2>&1 && \
        lsb_release -a | grep "ubuntu" > /dev/null 2>&1; then
        OS_TYPE="ubuntu"
    fi
}

install_haproxy_centos() {
    yum makecache
    yum install -y haproxy
}

install_haproxy_ubuntu() {
    apt-get update
    apt-get install -y haproxy
}

install_haproxy() {
    echo "Install haproxy by package manager ..."
    detect_os
    install_haproxy_${OS_TYPE}
    cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.dist
}

configure_haproxy() {
    echo "Generate haproxy configuration ..."
    sed \
        "s/LOCALPORT/${LOCALPORT}/;   \
         s/REMOTEHOST/${REMOTEHOST}/; \
         s/REMOTEPORT/${REMOTEPORT}/" \
         haproxy.cfg.template > haproxy.cfg
    cp haproxy.cfg /etc/haproxy/.
}

start_haproxy() {
    echo "Try to restart haproxy ..."
    killall haproxy || true
    haproxy -D -f /etc/haproxy/haproxy.cfg
    echo "Haproxy should have started to listen on $LOCALPORT"
}

main() {
    install_haproxy
    configure_haproxy
    start_haproxy
}

LOCALPORT=$1
REMOTEHOST=$2
REMOTEPORT=$3
main
