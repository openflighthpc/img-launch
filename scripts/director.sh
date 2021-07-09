#!/bin/bash
#
# Profile Script for a Director VM
#

#
# Setup as Gateway
#
firewall-offline-cmd --add-masquerade --zone public 
firewall-offline-cmd --add-interface $EXT_IFACE --zone public 
