#!/bin/bash

# Variables
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. >/dev/null 2>&1 && pwd )"

# Gather config
source $DIR/global.config.sh
source $DIR/config.sh

echo "WARNING: This script will delete the VM and associated disks as specified in config.sh"
echo
read -p "Remove $VM_NAME and $VM_DISK? [y/N] " answer

case $answer in
    y|Y)
        echo "Deleting..."
        virsh destroy $VM_NAME
        virsh undefine $VM_NAME
        rm -f $VM_DISK
        ;;
    *)
        echo "Not deleting anything."
        ;;
esac

