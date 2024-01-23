#!/bin/bash
set -euo pipefail

DEST="${NV_EXE_DIR}/yq"

sudo wget -q -O "${DEST}" \
  "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${NV_ARCH}"

sudo chmod +x "${DEST}"

yq --version
