#!/bin/bash

#
# Gateway Client Script
#
if [[ "$PRI_IP" != "$GW_IP" ]] ; then
    echo "---- Applying Gateway Client Configuration ----"
    curl http://$GW_IP/client/setup.sh |/bin/bash
fi

#
# Repo Client Script
#
if [[ "$PRI_IP" != "$REPO_IP" ]] ; then
    echo "---- Applying Repo Client Configuration ----"
    curl http://$REPO_IP/client/setup.sh |/bin/bash
fi

#
# Identity Client Script
#
if [[ "$PRI_IP" != "$IDENTITY_IP" ]] ; then
    echo "---- Applying Identity Client Configuration ----"
    curl http://$IDENTITY_IP/client/setup.sh |/bin/bash
fi
