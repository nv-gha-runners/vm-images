#!/bin/bash
set -euo pipefail

# Don't install CUDA Driver if NV_DRIVER_VERSION is not set
if [ "${NV_VARIANT}" != "gpu" ]; then
  echo "NV_VARIANT is not 'gpu'. Skipping CUDA Driver installation."
  exit 0
fi

ARCH=x86_64
if [ "${NV_ARCH}" == "arm64" ]; then
  ARCH=aarch64
fi

TMP_DIR=$(mktemp -d)
RUNFILE_NAME="NVIDIA-Linux-${ARCH}-${NV_DRIVER_VERSION}.run"
RUNFILE_URL="https://download.nvidia.com/XFree86/Linux-${ARCH}/${NV_DRIVER_VERSION}/${RUNFILE_NAME}"
RUNFILE_PATH="${TMP_DIR}/${RUNFILE_NAME}"

sudo apt-get update
sudo apt-get install -y --no-install-recommends build-essential

wget --no-verbose -O "${RUNFILE_PATH}" "${RUNFILE_URL}"
sudo sh "${RUNFILE_PATH}" --no-questions --ui=none
rm -rf "${TMP_DIR}"

sudo apt-get purge build-essential --autoremove -y
