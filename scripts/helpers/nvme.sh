#!/bin/bash
set -euo pipefail

if [ "${NV_RUNNER_ENV}" != "aws" ]; then
  echo "Not running on AWS. Exiting without doing anything"
  exit 0
fi

for disk in $(lsblk -n -e 7 -d -o NAME); do
  echo "Checking if disk $disk is already mounted"
  if grep "$disk" /proc/mounts; then
    echo "Disk $disk already mounted. Skipping"
    continue
  fi

  echo "Using disk $disk for /data mountpoint"
  mkfs -t xfs -f "/dev/$disk"
  rm -rf /data
  mkdir /data
  mount "/dev/$disk" /data
  exit 0
done
