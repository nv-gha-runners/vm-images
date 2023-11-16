#!/bin/bash
set -euo pipefail

echo "Trying to fetch JITConfig"
if [ ! -f "/jitconfig" ]; then
  echo "JITConfig not found. Exiting."
  # TODO: either poweroff here or set a trap
  # statement higher up to power off upon exit
  exit 1
fi

export ACTIONS_RUNNER_INPUT_JITCONFIG="$(cat /jitconfig)"

echo "Removing JITConfig file"
sudo rm -f /jitconfig

echo "Creating work directory"
if [ -e "/dev/nvme1n1" ] && [ "${NV_RUNNER_ENV}" = "aws" ]; then
  sudo mkfs -t xfs /dev/nvme1n1
  sudo mkdir /data
  sudo mount /dev/nvme1n1 /data
fi

WORK_DIR="/data/runner"
_UID=$(id -u)
_GID=$(id -g)
sudo mkdir -p "${WORK_DIR}"
sudo chown -R "${_UID}:${_GID}" "${WORK_DIR}"

echo "Starting runner"
cd /data/runner
# TODO: Consider moving poweroff to systemd service
/home/runner/bin/runsvc.sh && sudo poweroff
