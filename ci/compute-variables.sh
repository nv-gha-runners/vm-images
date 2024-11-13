#!/bin/bash
# A script that computes the variables for our GHAs workflows
set -euo pipefail

IMAGE_NAME=$(ci/image-name/serialize.sh)

cat <<EOF | tee --append "${GITHUB_ENV:-/dev/null}"
NV_IMAGE_NAME=${IMAGE_NAME}
NV_RUN_ID=${GITHUB_RUN_ID}-${GITHUB_RUN_ATTEMPT}
EOF
