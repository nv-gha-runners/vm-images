#!/bin/bash
set -euo pipefail

VARIANT=gpu
if [ -z "${DRIVER_VERSION}" ]; then
  VARIANT=cpu
fi

export VARIANT

RUN_ID=$(
  jq -nr '[
    env.OS,
    env.VARIANT,
    env.DRIVER_VERSION,
    env.ARCH,
    env.RUNNER_VERSION
  ] | map(select(length > 0)) | join("-")'
)

echo -n "${RUN_ID}"
