#!/bin/bash
#
# IPA Server Setup Script
#

#
# Generate password and save locally
#
PASSWORD="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)"
PASSWORDFILE="/root/ipa_auth.txt"

echo "IPA Admin Password: $PASSWORD" > $PASSWORDFILE
chmod 400 $PASSWORDFILE

#
# Install packages
#
yum -y install ipa-server bind bind-dyndb-ldap ipa-server-dns

#
# Server install
#

# GW_IP should use site IP of gateway for forwarding?
ipa-server-install -a $PASSWORD \
                   --hostname $VM_NAME.$DOMAIN \
                   --ip-address=$SITE_IP \
                   --realm "${DOMAIN^^}" \
                   --ds-password $PASSWORD \
                   --domain "$DOMAIN" \
                   --no-ntp --setup-dns \
                   --forwarder="$GW_IP" \
                   --reverse-zone="$(echo "$SITE_IP" |cut -d '.' -f2,1).in-addr.arpa." \
                   --ssh-trust-dns --unattended

# Login
echo "$PASSWORD" |kinit admin

#
# Add Cluster Primary DNS Zone
#
ipa dnszone-add pri.$CLUSTER_DOMAIN
ipa dnszone-add $(echo "$PRI_IP" |cut -d '.' -f2,1).in-addr.arpa.

#
# Mail Entry
#
ipa dnsrecord-add pri.$CLUSTER_DOMAIN @ --mx-preference=0 --mx-exchanger=$GW_IP

#
# User Configuration
#
ipa config-mod --defaultshell /bin/bash
ipa config-mod --homedirectory /users
ipa group-add ClusterUsers --desc="Generic Cluster Users"
ipa group-add AdminUsers --desc="Admin Cluster Users"
ipa config-mod --defaultgroup ClusterUsers
ipa pwpolicy-mod --maxlife=999

#
# Host Groups
#
ipa hostgroup-add usernodes --desc "All nodes allowing standard user access"
ipa hostgroup-add adminnodes --desc "All nodes allowing only admin user access"

#
# Access Rules
#
ipa hbacrule-disable allow_all
ipa hbacrule-add siteaccess --desc "Allow admin access to admin hosts"
ipa hbacrule-add useraccess --desc "Allow user access to user hosts"
ipa hbacrule-add-service siteaccess --hbacsvcs sshd
ipa hbacrule-add-service useraccess --hbacsvcs sshd
ipa hbacrule-add-user siteaccess --groups AdminUsers
ipa hbacrule-add-user useraccess --groups ClusterUsers
ipa hbacrule-add-host siteaccess --hostgroups adminnodes
ipa hbacrule-add-host useraccess --hostgroups usernodes

#
# Sudo Rules
#
ipa sudorule-add --cmdcat=all All
ipa sudorule-add-user --groups=adminusers All
ipa sudorule-mod All --hostcat='all'
ipa sudorule-add-option All --sudooption '!authenticate'

#
# Alces User 
#
alcespass="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)"
echo "Alces User Password: $alcespass" >> $PASSWORDFILE

echo "$alcespass" |ipa user-add alces-cluster --first Alces --last Software --random
ipa group-add-member AdminUsers --users alces-cluster

#
# Site User, Group & Sudo Rules
#
sitepass="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)"
echo "Site User Password: $sitepass" >> $PASSWORDFILE 

echo "$sitepass" |ipa user-add siteadmin --first Site --last Admin --password
ipa group-add siteadmins --desc="Site admin users (power users)"
ipa hostgroup-add sitenodes --desc "All nodes allowing site admin access"
ipa group-add-member siteadmins --users siteadmin

ipa hbacrule-add siteaccess --desc "Allow siteadmins access to site hosts"
ipa hbacrule-add-service siteaccess --hbacsvcs sshd
ipa hbacrule-add-user siteaccess --groups siteadmins
ipa hbacrule-add-host siteaccess --hostgroups sitenodes
ipa hbacrule-add-service useraccess --hbacsvcgroups=Sudo
ipa hbacrule-add-service siteaccess --hbacsvcgroups=Sudo

ipa sudorule-add --cmdcat=all Site
ipa sudorule-add-user --groups=siteadmins Site
ipa sudorule-mod Site --hostcat=''
ipa sudorule-add-option Site --sudooption '!authenticate'
ipa sudorule-add-host Site --hostgroups=sitenodes

#
# Update name resolution
#
cat << EOF > /etc/resolv.conf
search pri.$CLUSTER_NAME pri.$CLUSTER_NAME.$SITE_NAME pri.$CLUSTER_DOMAIN $CLUSTER_DOMAIN $DOMAIN
nameserver $SITE_IP
EOF

#
# Helper Script
#
IPASCRIPTS=/root/ipa_utils
mkdir -p $IPASCRIPTS

clientpass="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)"
echo "Host Client Password: $clientpass" >> $PASSWORDFILE

cat << EOF > $IPASCRIPTS/addhost.sh
host=\$1
ip=\$2

if [ -z "\$host" ] ; then
    echo "Please provide a host"
    echo "    addhost.sh HOST IP"
    exit 1
fi

if [ -z "\$ip" ] ; then
    echo "Please provide an IP"
    echo "    addhost.sh HOST IP"
    exit 1
fi

grep "^IPA Admin Password" $PASSWORDFILE |sed "s/.*: //g" |kinit admin

ipa host-add \$host.pri.$CLUSTER_DOMAIN --password="$clientpass" --ip-address=\$ip
EOF

#
# Client Setup Script
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
# Setup IPA Client
#
yum -y install ipa-client ipa-admintools

cat << EOD > /etc/resolv.conf
search pri.$CLUSTER_NAME pri.$CLUSTER_NAME.$SITE_NAME pri.$CLUSTER_DOMAIN $CLUSTER_DOMAIN $DOMAIN
nameserver $SITE_IP
EOD

ipa-client-install --no-ntp --mkhomedir --no-ssh --no-sshd --force-join --realm="${DOMAIN^^}" --server="$SITE_IP" -w "$clientpass" --domain="pri.$CLUSTER_DOMAIN" --unattended --hostname="\$(hostname -f)"
EOF

systemctl enable httpd
systemctl restart httpd
