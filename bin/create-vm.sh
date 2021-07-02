#!/bin/bash

# Variables
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. >/dev/null 2>&1 && pwd )"

# Gather config
source $DIR/config.sh

echo "==== CREATING VIRTUAL MACHINE ===="

if ! [ -x /usr/bin/virt-install ]; then
  echo "You need to install libvirt virt-install" >&2
  exit 1
fi

if ! [ -d $VM_PATH ]; then
  mkdir -p $VM_PATH
fi

if [ -f $VM_DISK ]; then
  echo "A Disk/VM by the name of $VM_NAME already seems to exist" >&2
  exit 1
fi

echo "---- Creating Disk ----"
qemu-img convert -p -f raw -O qcow2 $DIR/$SOURCE_IMG $VM_DISK
qemu-img resize $VM_DISK $DISK_SIZE
echo "---- Finished Creating Disk ----"

echo "---- Building VM ----"
virt-install \
--name $VM_NAME \
--import \
--ram 2048 \
--disk $VM_DISK,device=disk,bus=virtio \
--disk $BUILD/userdata.iso,device=cdrom,bus=scsi \
--vcpus 2 \
--os-type linux \
--os-variant centos7.0 \
--network bridge=$PRI_BRIDGE \
--network bridge=$EXT_BRIDGE \
--console pty,target_type=serial \
--graphics vnc,listen=0.0.0.0,port='-1' \
--noautoconsole
echo "---- Finished Building VM ----"

echo "==== FINISHED CREATING VIRTUAL MACHINE ===="
