# Input
SOURCE_IMG="images/"
VM_PATH="/opt/vm"

# Network
PRI_BRIDGE="pri"
EXT_BRIDGE="ext"

# Build
VM_NAME="director"
DOMAIN="cluster.compute.estate"
PROFILE_SCRIPT="director.sh"

DEFAULT_USER="flightadmin"
SSH_PUB_KEY="ssh-rsa MY_KEY_HERE user@host"
ROOT_PASS="ReplaceMe"

DISK_SIZE="128G"

######################
# DO NOT TOUCH BELOW #
######################

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BUILD="$DIR/build/$VM_NAME"
VM_DISK="$VM_PATH/$VM_NAME.qcow2"
