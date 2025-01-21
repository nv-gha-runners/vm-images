#!/bin/bash
set -euo pipefail

trap "sudo poweroff" EXIT

echo "Trying to fetch JITConfig"
if [ ! -f "/jitconfig" ]; then
  echo "JITConfig not found. Exiting."
  exit 1
fi

ACTIONS_RUNNER_INPUT_JITCONFIG="$(cat /jitconfig)"
ACTIONS_RUNNER_HOOK_JOB_STARTED=/home/runner/.initialize_runner.sh
NVIDIA_VISIBLE_DEVICES=all
# DOTNET fix for: https://github.com/actions/runner/issues/3583
# taken from: https://github.com/kernel-patches/runner/pull/61
DOTNET_EnableWriteXorExecute=0
export \
  ACTIONS_RUNNER_INPUT_JITCONFIG \
  ACTIONS_RUNNER_HOOK_JOB_STARTED \
  NVIDIA_VISIBLE_DEVICES \
  DOTNET_EnableWriteXorExecute

echo "Removing JITConfig file"
sudo rm -f /jitconfig

echo "Starting runner"
cd "${HOME}"
./bin/runsvc.sh
