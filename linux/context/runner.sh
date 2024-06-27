#!/bin/bash
set -euo pipefail

trap "sudo poweroff -ff" EXIT

echo "Trying to fetch JITConfig"
if [ ! -f "/jitconfig" ]; then
  echo "JITConfig not found. Exiting."
  exit 1
fi

ACTIONS_RUNNER_INPUT_JITCONFIG="$(cat /jitconfig)"
ACTIONS_RUNNER_HOOK_JOB_STARTED=/home/runner/.initialize_runner.sh
NVIDIA_VISIBLE_DEVICES=all
export ACTIONS_RUNNER_INPUT_JITCONFIG ACTIONS_RUNNER_HOOK_JOB_STARTED NVIDIA_VISIBLE_DEVICES

echo "Removing JITConfig file"
sudo rm -f /jitconfig

echo "Starting runner"
cd "${HOME}"
./bin/runsvc.sh
