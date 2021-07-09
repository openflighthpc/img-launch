#!/bin/bash

# Variables
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. >/dev/null 2>&1 && pwd )"

# Gather config
source $DIR/config.sh

echo "==== APPLYING PROFILE CONFIGURATION ===="

EXT_MAC="$(virsh domiflist $VM_NAME |grep $EXT_BRIDGE |awk '{print $5}')"
IP="$(arp -e |grep $EXT_MAC |awk '{print $1}')"

SSH_ARGS='-o StrictHostKeyChecking=no -o PasswordAuthentication=no'

SCRIPT="$(cat << EOF
$(cat $DIR/config.sh)
$(echo "---- Applying Base Configuration ----")
$(cat $DIR/scripts/base.sh)
$(echo "---- Applying Profile Configuration ($PROFILE_SCRIPT) ----")
$(cat $DIR/scripts/$PROFILE_SCRIPT)
EOF
)"

ssh $SSH_ARGS root@$IP "echo '$SCRIPT' > /tmp/flightscript.sh ; bash /tmp/flightscript.sh"

echo "==== FINISHED APPLYING PROFILE CONFIGURATION TO IP: $IP ===="
