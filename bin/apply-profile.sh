#!/bin/bash

# Variables
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. >/dev/null 2>&1 && pwd )"

# Gather config
source $DIR/global.config.sh
source $DIR/config.sh

echo "==== APPLYING PROFILE CONFIGURATION ===="

SSH_ARGS='-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o PasswordAuthentication=no'

SCRIPT="$(cat << EOF
$(cat $DIR/global.config.sh)
$(cat $DIR/config.sh)
echo "---- Applying Client Configuration ----"
$(cat $DIR/scripts/client.sh)
echo "---- Applying Base Configuration ----"
$(cat $DIR/scripts/base.sh)
echo "---- Applying Profile Configuration ($PROFILE_SCRIPT) ----"
$(cat $DIR/scripts/$PROFILE_SCRIPT)
EOF
)"

ssh $SSH_ARGS root@$PRI_IP "echo '$SCRIPT' > /tmp/flightscript.sh ; bash /tmp/flightscript.sh"

echo "==== FINISHED APPLYING PROFILE CONFIGURATION TO IP: $PRI_IP ===="
