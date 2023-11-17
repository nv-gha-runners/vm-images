#!/bin/bash
set -euo pipefail

if [ -e "/dev/nvme1n1" ] && [ "${NV_RUNNER_ENV}" = "aws" ]; then
  echo "nvme drive found. mounting..."
  mkfs -t xfs /dev/nvme1n1
  mkdir /data
  mount /dev/nvme1n1 /data
else
  echo "nvme drive not found. exiting..."
fi
