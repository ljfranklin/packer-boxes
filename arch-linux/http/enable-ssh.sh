#!/bin/bash

set -eu

# Root login will be enabled on the live cd system, not the target system
sed -i'' 's/^#?PermitRootLogin \(no\|yes\)/PermitRootLogin yes/' /etc/ssh/sshd_config
chpasswd <<< "root:root"
systemctl restart sshd
sleep 5
