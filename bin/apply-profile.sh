#!/bin/bash

# Variables
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. >/dev/null 2>&1 && pwd )"

# Gather config
source $DIR/config.sh

echo "==== APPLYING PROFILE CONFIGURATION ===="

EXT_MAC="$(virsh domiflist $VM_NAME |grep $EXT_BRIDGE |awk '{print $5}')"
IP="$(arp -e |grep $EXT_MAC |awk '{print $1}')"

scp $DIR/scripts/$PROFILE_SCRIPT root@$IP:/tmp/$PROFILE_SCRIPT
ssh root@$IP "bash /tmp/$PROFILE_SCRIPT"

echo "==== FINISHED APPLYING PROFILE CONFIGURATION"
