#!/bin/bash
# A script that computes the variables for our GHAs workflows
set -euo pipefail


VARIANT=gpu
if [ -z "${DRIVER_VERSION}" ]; then
  VARIANT=cpu
fi

IMAGE_NAME=$(
  jq -nr \
    --arg OS "${RUNNER_OS}" \
    --arg VARIANT "${VARIANT}" \
    --arg DRIVER_VERSION "${DRIVER_VERSION}" \
    --arg ARCH "${RUNNER_ARCH}" \
    --arg RUNNER_VERSION "${RUNNER_VERSION}" \
  '[
    $OS,
    $VARIANT,
    $DRIVER_VERSION,
    $ARCH,
    $RUNNER_VERSION
  ] | map(select(length > 0)) | join("-")'
)

cat <<EOF | tee --append "${GITHUB_ENV:-/dev/null}"
NV_IMAGE_NAME=${IMAGE_NAME}
NV_RUN_ID=${GITHUB_RUN_ID}-${GITHUB_RUN_ATTEMPT}
EOF
