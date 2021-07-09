#!/bin/bash

# Variables
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. >/dev/null 2>&1 && pwd )"

# Gather config
source $DIR/config.sh

echo "==== GENERATING CLOUD-INIT ISO ===="

if ! [ -d $BUILD ] ; then
    mkdir -p $BUILD
fi

if ! [ -f ~/.ssh/id_rsa.pub ] ; then
    echo "No SSH public key configured for build server"
    echo "Place a key at ~/.ssh/id_rsa.pub"
    echo "This key will be used for applying profile scripts to machines"
    exit 1
fi

cat << EOF > $BUILD/meta-data
instance-id: iid-local01
dsmode: local
local-hostname: $VM_NAME.$DOMAIN
hostname: $VM_NAME.$DOMAIN
fqdn: $VM_NAME.$DOMAIN
network:
  config: disabled
public-keys:
  - $SSH_PUB_KEY
  - $(cat ~/.ssh/id_rsa.pub)
EOF

cat << EOF > $BUILD/user-data
#cloud-config
disable_root: 0
ssh_pwauth:   1
chpasswd:
  expire: false
  list: |
     root:$ROOT_PASS
system_info:
  default_user:
    name: $DEFAULT_USER
    lock_passwd: true
    gecos: Local Administrator
    groups: [wheel, adm, systemd-journal]
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
network:
  config: disabled
rumcmd:
  - ping -c 1 $MASTER_IP # Ensure ARP cache is populated
  - echo "nameserver 8.8.8.8" > /etc/resolv.conf; rm -fv /etc/NetworkManager/conf.d/99-disableNMDNS.conf # Fix for EL7 DNS issues
EOF

mkisofs -o $BUILD/userdata.iso -V cidata -J $BUILD/meta-data $BUILD/user-data

echo "==== FINISHED GENERATING CLOUD-INIT ISO ===="

