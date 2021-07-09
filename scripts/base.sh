#!/bin/bash
#
# Base Script for All Systems
#

yum -y install firewalld
systemctl enable firewalld
systemctl start firewalld

#
# Network setup
#

cat << EOF >> /etc/hosts
# $VM_NAME
$SITE_IP    $VM_NAME.$DOMAIN $VM_NAME.$SITE_NAME $VM_NAME
$PRI_IP    $VM_NAME.pri.$CLUSTER_DOMAIN $VM_NAME.pri.$CLUSTER_NAME.$SITE_NAME $VM_NAME.pri.$CLUSTER_NAME
$MGT_IP    $VM_NAME.mgt.$CLUSTER_DOMAIN $VM_NAME.mgt.$CLUSTER_NAME.$SITE_NAME $VM_NAME.mgt.$CLUSTER_NAME
EOF


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

    firewall-offline-cmd --new-zone site 
    firewall-offline-cmd --set-target=ACCEPT --zone site 
    firewall-offline-cmd --zone site --add-interface $SITE_IFACE 
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

    firewall-offline-cmd --new-zone cluster1 
    firewall-offline-cmd --set-target=ACCEPT --zone cluster1 
    firewall-offline-cmd --zone cluster1 --add-interface $PRI_IFACE 

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

    firewall-offline-cmd --new-zone cluster1mgt 
    firewall-offline-cmd --set-target=ACCEPT --zone cluster1mgt 
    firewall-offline-cmd --zone cluster1mgt --add-interface $MGT_IFACE 
fi

firewall-cmd --reload

#
# Disable Cloud Init
#

#disable cloudinit on next run
touch /etc/cloud/cloud-init.disabled

systemctl disable cloud-init
systemctl disable cloud-config
systemctl disable cloud-final
systemctl disable cloud-init-local

#
# System Config
#

cat << EOF > /etc/profile.d/flightcenter.sh
#Custom PS1 with client name
[ -f /etc/flightcentersupported ] && c=32 || c=31
if [ "\$PS1" ]; then
  PS1="[\u@\h\[\e[1;\${c}m\] [$VM_NAME-$SITE_NAME]\[\e[0m\] \W]\\$ "
fi
EOF
touch /etc/flightcentersupported

sed -i -e 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

echo 'ZONE="Europe/London"' > /etc/sysconfig/clock
ln -snf /usr/share/zoneinfo/Europe/London /etc/localtime


yum -y update
