#!/bin/bash

# Variables
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. >/dev/null 2>&1 && pwd )"

# Gather config
source $DIR/config.sh

# Generate Cloud-init
bash $DIR/bin/gen-cloud-init.sh

# Build VM
bash $DIR/bin/create-vm.sh

# Apply customisations
bash $DIR/bin/apply-profile.sh
