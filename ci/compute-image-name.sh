#!/bin/bash
# This script computes the image name from the environment variables provided by
# GitHub Actions.
set -euo pipefail

VARIANT=gpu
if [ -z "${DRIVER_VERSION}" ]; then
  VARIANT=cpu
fi

export VARIANT

IMAGE_NAME=$(
  jq -nr '[
    env.OS,
    env.VARIANT,
    env.DRIVER_VERSION,
    env.ARCH,
    env.RUNNER_VERSION
  ] | map(select(length > 0)) | join("-")'
)

echo -n "${IMAGE_NAME}"
