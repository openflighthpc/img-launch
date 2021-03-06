#!/bin/bash
#
# Base Script for All Systems
#

#
# Hosts setup
#

hostentries="$(
[[ ! -z "$SITE_BRIDGE" ]] && echo "$SITE_IP    $VM_NAME.$DOMAIN $VM_NAME.$SITE_NAME $VM_NAME"
[[ ! -z "$PRI_BRIDGE" ]] && echo "$PRI_IP    $VM_NAME.pri.$CLUSTER_DOMAIN $VM_NAME.pri.$CLUSTER_NAME.$SITE_NAME $VM_NAME.pri.$CLUSTER_NAME"
[[ ! -z "$MGT_BRIDGE" ]] && echo "$MGT_IP    $VM_NAME.mgt.$CLUSTER_DOMAIN $VM_NAME.mgt.$CLUSTER_NAME.$SITE_NAME $VM_NAME.mgt.$CLUSTER_NAME"
)"

cat << EOF >> /etc/hosts
# $VM_NAME
$hostentries
EOF

#
# Firewall setup
#

yum -y install firewalld
systemctl enable firewalld

if [[ ! -z "$SITE_BRIDGE" ]] ; then
    firewall-offline-cmd --new-zone site 
    firewall-offline-cmd --set-target=ACCEPT --zone site 
    firewall-offline-cmd --zone site --add-interface $SITE_IFACE 
fi


if [[ ! -z "$PRI_BRIDGE" ]] ; then
    firewall-offline-cmd --new-zone cluster1 
    firewall-offline-cmd --set-target=ACCEPT --zone cluster1 
    firewall-offline-cmd --zone cluster1 --add-interface $PRI_IFACE 

fi

if [[ ! -z "$MGT_BRIDGE" ]] ; then
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
# Restart Network for New Interfaces
#
systemctl restart network

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
yum -y install git vim wget
