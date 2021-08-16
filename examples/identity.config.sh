# Input
SOURCE_IMG="images/"
VM_PATH="/opt/vm"

# Network
## Blank bridges will be ignored, networks will not be set up for empty vars
EXT_BRIDGE="" 
EXT_IFACE=""

SITE_BRIDGE="site"
SITE_IFACE="eth1"
SITE_IP="10.254.254.51"

PRI_BRIDGE="pri"
PRI_IFACE="eth2"
PRI_IP="10.10.254.51"

MGT_BRIDGE=""
MGT_IFACE=""
MGT_IP=""

# Build
VM_NAME="identity"
SITE_NAME="site"
CLUSTER_NAME="cluster"
DOMAIN="$SITE_NAME.compute.estate"
CLUSTER_DOMAIN="$CLUSTER_NAME.$DOMAIN"
PROFILE_SCRIPT="identity.sh"

DEFAULT_USER="flightadmin"
SSH_PUB_KEY="ssh-rsa MY_KEY_HERE user@host"
ROOT_PASS="ReplaceMe"

DISK_SIZE="128G"

######################
# DO NOT TOUCH BELOW #
######################

SITE_NET="$(echo "$SITE_IP" |cut -d '.' -f1,2).0.0"
PRI_NET="$(echo "$PRI_IP" |cut -d '.' -f1,2).0.0"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BUILD="$DIR/build/$VM_NAME"
VM_DISK="$VM_PATH/$VM_NAME.qcow2"

