#!/bin/bash
# This script computes the image name from the environment variables provided by
# GitHub Actions.
set -euo pipefail

VARIANT=gpu
if [ -z "${DRIVER_VERSION}" ]; then
  VARIANT=cpu
fi

DRIVER_VERSION_SHORT="${DRIVER_VERSION%%.*}"

IMAGE_NAME=$(
  jq -nr \
    --arg OS "${OS}" \
    --arg VARIANT "${VARIANT}" \
    --arg DRIVER_VERSION_SHORT "${DRIVER_VERSION_SHORT}" \
    --arg ARCH "${ARCH}" \
    --arg RUNNER_VERSION "${RUNNER_VERSION}" \
  '[
    $OS,
    $VARIANT,
    $DRIVER_VERSION_SHORT,
    $ARCH,
    $RUNNER_VERSION
  ] | map(select(length > 0)) | join("-")'
)

echo -n "${IMAGE_NAME}"
