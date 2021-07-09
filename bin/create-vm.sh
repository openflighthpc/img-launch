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
echo "---- Resizing Disk ----"
qemu-img resize $VM_DISK $DISK_SIZE

echo "---- Building VM ----"
NET_ARGS="$(
[[ ! -z "$EXT_BRIDGE" ]] && echo "--network bridge=$EXT_BRIDGE "
[[ ! -z "$SITE_BRIDGE" ]] && echo "--network bridge=$SITE_BRIDGE "
[[ ! -z "$PRI_BRIDGE" ]] && echo "--network bridge=$PRI_BRIDGE "
[[ ! -z "$MGT_BRIDGE" ]] && echo "--network bridge=$MGT_BRIDGE "
)"

virt-install \
--name $VM_NAME \
--import \
--ram 2048 \
--disk $VM_DISK,device=disk,bus=virtio \
--disk $BUILD/userdata.iso,device=cdrom,bus=scsi \
--vcpus 2 \
--os-type linux \
--os-variant centos7.0 \
$NET_ARGS \
--console pty,target_type=serial \
--graphics vnc,listen=0.0.0.0,port='-1' \
--noautoconsole

echo "==== FINISHED CREATING VIRTUAL MACHINE ===="
