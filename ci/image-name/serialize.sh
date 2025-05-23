#!/bin/bash
# This script computes the image name from the environment variables provided by
# GitHub Actions.
set -euo pipefail

VARIANT=gpu
if [ -z "${DRIVER_VERSION}" ]; then
  VARIANT=cpu
fi

IMAGE_NAME=$(
  jq -nr \
    --arg OS "${OS}" \
    --arg VARIANT "${VARIANT}" \
    --arg DRIVER_VERSION "${DRIVER_VERSION}" \
    --arg DRIVER_FLAVOR "${DRIVER_FLAVOR}" \
    --arg ARCH "${ARCH}" \
    --arg BRANCH_NAME "${BRANCH_NAME}" \
  '[
    $OS,
    $VARIANT,
    $DRIVER_VERSION,
    $DRIVER_FLAVOR,
    $ARCH,
    $BRANCH_NAME | sub("/"; "-")
  ] | map(select(length > 0)) | join("-")'
)

echo -n "${IMAGE_NAME}"
