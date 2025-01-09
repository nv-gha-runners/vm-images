#!/bin/bash

set -eu

# these strings are case-sensitive and should match the case of the GH org
CLOUD_ONLY_ORGS=(
  "dask-contrib"
  "dask"
  "NERSC"
  "numba"
)

for ORG in "${CLOUD_ONLY_ORGS[@]}"; do
  if [ "${GITHUB_REPOSITORY_OWNER}" = "${ORG}" ] ; then
    echo "Runner initialized"
    exit 0
  fi
done

BLOCKED_EVENTS=(
  "pull_request"
  "pull_request_target"
)

for EVENT in "${BLOCKED_EVENTS[@]}"; do
  if [ "${GITHUB_EVENT_NAME}" = "${EVENT}" ] ; then
    echo "Workflows triggered by \"${GITHUB_EVENT_NAME}\" events are not allowed to run on self-hosted runners."
    exit 1
  fi
done

echo "Dump env"
env | sort

echo "Runner initialized"
exit 0
