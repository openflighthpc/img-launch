#!/bin/bash
#
# Profile Script for a Gateway VM
#

#
# Firewall Config
#
firewall-offline-cmd --add-masquerade --zone public
firewall-offline-cmd --add-interface $EXT_IFACE --zone public

# For forwarding cluster1 pri traffic to site traffic
firewall-offline-cmd --add-masquerade --zone site


#
# DNS Forwarding
#
yum install -y dnsmasq

systemctl start dnsmasq
systemctl enable dnsmasq

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

mkdir -p /opt/flight/client

cat << EOF > /opt/flight/client/setup.sh
#
# Setup GW Client
#
IFACE="eth0"
NET="\$(grep "^IPADDR" /etc/sysconfig/network-scripts/ifcfg-\$IFACE |sed "s/IPADDR=//g" |cut -d "." -f1,2)"
GW_IP_END="$(echo "$SITE_IP" |cut -d '.' -f3,4)"
grep -q GATEWAY /etc/sysconfig/network-scripts/ifcfg-\$IFACE && sed -i "s/GATEWAY=.*/GATEWAY=\$NET.\$GW_IP_END/g" /etc/sysconfig/network-scripts/ifcfg-\$IFACE || echo "GATEWAY=\$NET.\$GW_IP_END" >> /etc/sysconfig/network-scripts/ifcfg-\$IFACE
grep -q DNS1 /etc/sysconfig/network-scripts/ifcfg-\$IFACE && sed -i "s/DNS1=.*/DNS1=\$NET.\$GW_IP_END/g" /etc/sysconfig/network-scripts/ifcfg-\$IFACE || echo "DNS1=\$NET.\$GW_IP_END" >> /etc/sysconfig/network-scripts/ifcfg-\$IFACE
sed -i "s/DEFROUTE=.*/DEFROUTE=yes/g" /etc/sysconfig/network-scripts/ifcfg-\$IFACE
ip route replace default via \$NET.\$GW_IP_END dev \$IFACE
echo "nameserver \$NET.\$GW_IP_END" >> /etc/resolv.conf
EOF

systemctl enable httpd
systemctl start httpd
