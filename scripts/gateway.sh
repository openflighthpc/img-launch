#!/bin/bash
#
# Profile Script for a Gateway VM
#

#
# Firewall Config
#
firewall-offline-cmd --add-masquerade --zone public
firewall-offline-cmd --add-interface $EXT_IFACE --zone public

#
# Client Script
#
yum -y install httpd

cat << EOF > /etc/httpd/conf.d/client.conf
<Directory /opt/flight/client/>
    Options Indexes MultiViews FollowSymlinks
    AllowOverride None
    Require all granted
    Order Allow,Deny
    Allow from $PRI_NET/16
    Allow from $SITE_NET/16
</Directory>
Alias /client /opt/flight/client/
EOF

mkdir /opt/flight/client

cat << EOF > /opt/flight/client/setup.sh
#
# Setup GW Client
#
IFACE="eth0"
NET="\$(ifconfig \$IFACE 2>/dev/null |awk '/inet / {print \$2}' |sed 's/addr://' |cut -d '.' -f1,2)"
GW_IP_END="$(echo "$SITE_IP" |cut -d '.' -f3,4)"
echo "default via \$NET.\$GW_IP_END dev \$IFACE" > /etc/sysconfig/network-scripts/route-\$IFACE
EOF

systemctl enable httpd
systemctl start httpd
