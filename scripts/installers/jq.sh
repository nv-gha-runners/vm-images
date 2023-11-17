#!/bin/bash
set -euo pipefail

DEST=/usr/local/bin/jq

sudo wget -q -O "${DEST}" \
  "https://github.com/jqlang/jq/releases/latest/download/jq-linux-${NV_ARCH}"

sudo chmod +x "${DEST}"

jq --version
