#!/bin/bash
set -euo pipefail

echo "Trying to fetch JITConfig"
if [ ! -f "/jitconfig" ]; then
  echo "JITConfig not found. Exiting."
  # TODO: either poweroff here or set a trap
  # statement higher up to power off upon exit
  exit 1
fi

ACTIONS_RUNNER_INPUT_JITCONFIG="$(cat /jitconfig)"
export ACTIONS_RUNNER_INPUT_JITCONFIG

echo "Removing JITConfig file"
sudo rm -f /jitconfig

echo "Creating work directory"
WORK_DIR="/data/runner"
_UID=$(id -u)
_GID=$(id -g)
sudo mkdir -p "${WORK_DIR}"
sudo chown "${_UID}:${_GID}" /data "${WORK_DIR}"
mv ~/* "${WORK_DIR}"

echo "Starting runner"
cd /data/runner
# TODO: Consider moving poweroff to systemd service
./bin/runsvc.sh && sudo poweroff
