#!/bin/bash
set -euo pipefail

DEST="${NV_EXE_DIR}/jq"

sudo wget -q -O "${DEST}" \
  "https://github.com/jqlang/jq/releases/latest/download/jq-linux-${NV_ARCH}"

sudo chmod +x "${DEST}"

jq --version
