#!/bin/bash

# Variables
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. >/dev/null 2>&1 && pwd )"

# Gather config
source $DIR/global.config.sh
source $DIR/config.sh

# Backup config
cp -vf $DIR/config.sh $BUILD/config.sh

# Generate Cloud-init
bash $DIR/bin/gen-cloud-init.sh

# Build VM
bash $DIR/bin/create-vm.sh

# Wait for VM to Boot
echo "==== WAITING FOR VM TO BOOT ===="
sleep 120

# Apply customisations
bash $DIR/bin/apply-profile.sh
