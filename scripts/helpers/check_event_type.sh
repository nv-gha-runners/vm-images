#!/bin/bash

set -eu

if [ "${GITHUB_EVENT_NAME}" = "pull_request" ] || [ "${GITHUB_EVENT_NAME}" = "pull_request_target" ]; then
  echo "Workflows triggered by \"${GITHUB_EVENT_NAME}\" events are not allowed to run on self-hosted runners."
  exit 1
fi

echo "Event \"${GITHUB_EVENT_NAME}\" allowed to run on self-hosted runners."
exit 0
