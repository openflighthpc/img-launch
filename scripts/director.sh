#!/bin/bash
#
# Profile Script for a Director VM
#

cat << 'EOF' > /etc/profile.d/director-prompt.sh
if [ "$PS1" ]; then
  PS1="[\u@\h\[\e[1;34m\] [Director]\[\e[0m\] \W]\\$ "
fi
EOF
