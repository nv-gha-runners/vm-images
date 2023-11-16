#!/bin/bash
set -euo pipefail

# the contents of this script were adapted from:
#  - https://github.com/actions/runner-images/blob/81ef6f228d68d81f3db70b80551aace30e2675b9/images/linux/scripts/installers/post-deployment.sh
#  - https://github.com/actions/runner-images/blob/81ef6f228d68d81f3db70b80551aace30e2675b9/images/linux/scripts/installers/cleanup.sh

echo "chmod -R 777 /usr/share"
sudo chmod -R 777 /usr/share

# before cleanup
before=$(df / -Pm | awk 'NR==2{print $4}')

# clears out the local repository of retrieved package files
# It removes everything but the lock file from /var/cache/apt/archives/ and /var/cache/apt/archives/partial
sudo apt-get clean
sudo rm -rf /tmp/*
sudo rm -rf /root/.cache

# journalctl
if command -v journalctl; then
    sudo journalctl --rotate
    sudo journalctl --vacuum-time=1s
fi

# delete all .gz and rotated file
sudo find /var/log -type f -regex ".*\.gz$" -delete
sudo find /var/log -type f -regex ".*\.[0-9]$" -delete

# wipe log files
sudo find /var/log/ -type f -exec cp /dev/null {} \;

# after cleanup
after=$(df / -Pm | awk 'NR==2{print $4}')

# display size
echo "Before: $before MB"
echo "After : $after MB"
echo "Delta : $(($after-$before)) MB"
