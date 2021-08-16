# Input
SOURCE_IMG="images/"
VM_PATH="/opt/vm"

# Network
## Blank bridges will be ignored, networks will not be set up for empty vars
EXT_BRIDGE="" 
EXT_IFACE=""

SITE_BRIDGE="site"
SITE_IFACE="eth0"
SITE_IP="10.254.254.101"

PRI_BRIDGE="pri"
PRI_IFACE="eth1"
PRI_IP="10.10.254.101"

MGT_BRIDGE="mgt"
MGT_IFACE="eth2"
MGT_IP="10.11.254.101"

# Build
MASTER_IP="10.151.0.1" # IP address of system running these scripts, used for populating ARP cache
VM_NAME="director"
SITE_NAME="site"
CLUSTER_NAME="cluster"
DOMAIN="$SITE_NAME.compute.estate"
CLUSTER_DOMAIN="$CLUSTER_NAME.$DOMAIN"
PROFILE_SCRIPT="director.sh"

DEFAULT_USER="flightadmin"
SSH_PUB_KEY="ssh-rsa MY_KEY_HERE user@host"
ROOT_PASS="ReplaceMe"

DISK_SIZE="128G"
RAM=2048 # MB

######################
# DO NOT TOUCH BELOW #
######################

SITE_NET="$(echo "$SITE_IP" |cut -d '.' -f1,2).0.0"
PRI_NET="$(echo "$PRI_IP" |cut -d '.' -f1,2).0.0"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BUILD="$DIR/build/$VM_NAME"
VM_DISK="$VM_PATH/$VM_NAME.qcow2"

