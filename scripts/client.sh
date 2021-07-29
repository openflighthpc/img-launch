#!/bin/bash

#
# Gateway Client Script
#
if [[ "$PRI_IP" != "$GW_IP" ]] ; then
    curl http://$GW_IP/client/setup.sh |/bin/bash
fi

#
# Repo Client Script
#
if [[ "$PRI_IP" != "$REPO_IP" ]] ; then
    curl http://$REPO_IP/client/setup.sh |/bin/bash
fi

#
# Identity Client Script
#

