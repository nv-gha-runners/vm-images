#!/bin/bash
set -euo pipefail

DEST=/usr/local/bin/yq

sudo wget -q -O "${DEST}" \
  "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${NV_ARCH}"

sudo chmod +x "${DEST}"
