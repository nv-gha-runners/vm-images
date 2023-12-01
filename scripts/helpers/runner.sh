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
ACTIONS_RUNNER_HOOK_JOB_STARTED=/home/runner/.check_event_type.sh
export ACTIONS_RUNNER_INPUT_JITCONFIG ACTIONS_RUNNER_HOOK_JOB_STARTED

echo "Removing JITConfig file"
sudo rm -f /jitconfig

echo "Starting runner"
cd "${HOME}"
# TODO: Consider moving poweroff to systemd service
./bin/runsvc.sh && sudo poweroff
