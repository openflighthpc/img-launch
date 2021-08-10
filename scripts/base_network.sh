#!/bin/bash

#
# Network setup
#

if [[ ! -z "$EXT_BRIDGE" ]] ; then

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-$EXT_IFACE
TYPE=Ethernet
BOOTPROTO=dhcp
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
NAME=$EXT_IFACE
DEVICE=$EXT_IFACE
ONBOOT=yes
ZONE=external
EOF

fi

if [[ ! -z "$SITE_BRIDGE" ]] ; then

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-$SITE_IFACE
TYPE=Ethernet
BOOTPROTO=none
DEFROUTE=no
PEERDNS=no
PEERROUTES=no
NAME=$SITE_IFACE
DEVICE=$SITE_IFACE
ONBOOT=yes
IPADDR=$SITE_IP
NETMASK=255.255.0.0
ZONE=site
EOF

fi


if [[ ! -z "$PRI_BRIDGE" ]] ; then

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-$PRI_IFACE
TYPE=Ethernet
BOOTPROTO=none
DEFROUTE=no
PEERDNS=no
PEERROUTES=no
NAME=$PRI_IFACE
DEVICE=$PRI_IFACE
ONBOOT=yes
IPADDR=$PRI_IP
NETMASK=255.255.0.0
ZONE=cluster1
EOF

fi

if [[ ! -z "$MGT_BRIDGE" ]] ; then

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-$MGT_IFACE
TYPE=Ethernet
BOOTPROTO=none
DEFROUTE=no
PEERDNS=no
PEERROUTES=no
NAME=$MGT_IFACE
DEVICE=$MGT_IFACE
ONBOOT=yes
IPADDR=$MGT_IP
NETMASK=255.255.0.0
ZONE=cluster1mgt
EOF

fi

#
# Restart Network for New Interfaces
#
systemctl restart network
