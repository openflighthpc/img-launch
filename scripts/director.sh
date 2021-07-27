#!/bin/bash
#
# Profile Script for a Director VM
#

#
# Setup as Gateway
#
firewall-offline-cmd --add-masquerade --zone public 
firewall-offline-cmd --add-interface $EXT_IFACE --zone public 

#
# HTTP Server & Deployment Files
#

yum -y install httpd

cat << EOF > /etc/httpd/conf.d/deployment.conf
<Directory /opt/flight/deployment/>
    Options Indexes MultiViews FollowSymlinks
    AllowOverride None
    Require all granted
    Order Allow,Deny
    Allow from $PRI_NET/16
</Directory>
Alias /deployment /opt/flight/deployment/
EOF

systemctl enable httpd
systemctl start httpd

mkdir /opt/flight
git clone https://github.com/alces-software/alces-cloud-cluster /opt/flight/deployment

#
# Repo Mirror
#
sed -i "s/^IP=.*/IP=$PRI_IP/g" /opt/flight/deployment/support/repoclone.sh
bash /opt/flight/deployment/support/repoclone.sh

#
# TFTP/Xinetd/PXE Server
#
yum -y install tftp xinetd tftp-server syslinux syslinux-tftpboot php

mkdir -p /var/lib/tftpboot/pxelinux.cfg/

sed -ie "s/^.*disable.*$/\    disable = no/g" /etc/xinetd.d/tftp

cat << EOF > /etc/xinetd.d/tftp
service tftp
{
    socket_type    = dgram
    protocol       = udp
    wait           = yes
    user           = root
    server         = /usr/sbin/in.tftpd
    server_args    = --verbosity=10 -s /var/lib/tftpboot
    disable        = no
    per_source     = 11
    cps            = 100 2
    flags          = IPv4
}
EOF

systemctl enable xinetd
systemctl restart xinetd

cat << EOF > /var/lib/tftpboot/pxelinux.cfg/default
DEFAULT menu
PROMPT 0
MENU TITLE PXE Menu
TIMEOUT 100
TOTALTIMEOUT 1000
ONTIMEOUT local


label local
 MENU LABEL (local)
 MENU DEFAULT
 LOCALBOOT 0

label install
  menu label ^Install system
  kernel /images/centos7/vmlinuz
  append initrd=/images/centos7/initrd.img ip=dhcp inst.repo=http://$PRI_IP/deployment/repo/centos-7-base/

label installvesa
  menu label Install system with ^basic video driver
  kernel /images/centos7/vmlinuz
  append initrd=/images/centos7/initrd.img ip=dhcp inst.xdriver=vesa nomodeset inst.repo=http://$PRI_IP/deployment/repo/centos-7-base/
EOF

cat << EOF > /var/lib/tftpboot/grub.cfg
set timeout=60
menuentry 'install' {
  linuxefi /images/centos7/vmlinuz ip=dhcp http://$PRI_IP/deployment/repo/centos-7-base/
  initrdefi /images/centos7/initrd.img
}
EOF

mkdir -p /var/lib/tftpboot/images/centos7/
cp -v /opt/flight/deployment/repo/centos-7-base/images/pxeboot/* /var/lib/tftpboot/images/centos7/.

rm -rfv /etc/yum.repos.d/*.repo
cp -v /opt/flight/deployment/repo/cluster.repo /etc/yum.repos.d/cluster.repo

yum clean all 
yum install -y flight-hunter flight-inventory
/opt/flight/bin/flenable --yes

yum clean all

#
# DHCP Server
#
yum install -y dhcp

cat << EOF > /etc/dhcp/dhcpd.conf
option space pxelinux;
option pxelinux.magic code 208 = string;
option pxelinux.configfile code 209 = text;
option pxelinux.pathprefix code 210 = text;
option pxelinux.reboottime code 211 = unsigned integer 32;
option architecture-type code 93 = unsigned integer 16;

#SITE RANGE
subnet $SITE_NET netmask 255.255.0.0 {
    option routers $SITE_IP;
    option domain-name-servers $SITE_IP;
    pool
    {
      range $(echo "$SITE_IP" |cut -d '.' -f1,2).250.1 $(echo "$SITE_IP" |cut -d '.' -f1,2).250.254;
    }

    class "pxeclients" {
      match if substring (option vendor-class-identifier, 0, 9) = "PXEClient";
      next-server $PRI_IP;

      if option architecture-type = 00:07 {
        filename "shim.efi";
      } else {
        filename "pxelinux.0";
        }
    }
}


#CLUSTER1 PRIVATE RANGE
subnet $PRI_NET netmask 255.255.0.0 {
    option routers $PRI_IP;
    option domain-name-servers $PRI_IP;
    pool
    {
      range $(echo "$PRI_IP" |cut -d '.' -f1,2).250.1 $(echo "$PRI_IP" |cut -d '.' -f1,2).250.254;
    }

    class "pxeclients" {
      match if substring (option vendor-class-identifier, 0, 9) = "PXEClient";
      next-server $PRI_IP;

      if option architecture-type = 00:07 {
        filename "shim.efi";
      } else {
        filename "pxelinux.0";
        }
    }
}
EOF

systemctl enable dhcpd
systemctl restart dhcpd

#
# Client Script
#
cat << EOF > /etc/httpd/conf.d/client.conf
<Directory /opt/flight/client/>
    Options Indexes MultiViews FollowSymlinks
    AllowOverride None
    Require all granted
    Order Allow,Deny
    Allow from $PRI_NET/16
</Directory>
Alias /client /opt/flight/client/
EOF

mkdir /opt/flight/client

cat << EOF > /opt/flight/client/setup.sh
#
# Setup Repo Client
#
rm -f /etc/yum.repos.d/*.repo
curl http://$PRI_IP/deployment/repo/cluster.repo > /etc/yum.repos.d/cluster.repo
yum clean all
EOF

systemctl restart httpd
