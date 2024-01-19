#!/bin/bash
set -euo pipefail

echo "Trying to fetch JITConfig"
if [ ! -f "/jitconfig" ]; then
  echo "JITConfig not found. Exiting."
  exit 1
fi

ACTIONS_RUNNER_INPUT_JITCONFIG="$(cat /jitconfig)"
ACTIONS_RUNNER_HOOK_JOB_STARTED=/home/runner/.initialize_runner.sh
PARALLEL_LEVEL=$(nproc)
export ACTIONS_RUNNER_INPUT_JITCONFIG ACTIONS_RUNNER_HOOK_JOB_STARTED PARALLEL_LEVEL

echo "Removing JITConfig file"
sudo rm -f /jitconfig

echo "Starting runner"
cd "${HOME}"
./bin/runsvc.sh
