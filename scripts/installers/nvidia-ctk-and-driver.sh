#!/bin/bash
set -euo pipefail

# Don't install CUDA Toolkit and Driver if NV_DRIVER_VERSION is not set
if [ "${NV_VARIANT}" != "gpu" ]; then
  echo "NV_VARIANT is not 'gpu'. Skipping CUDA Toolkit and Driver installation."
  exit 0
fi

KEYRING=cuda-keyring_1.1-1_all.deb
ARCH=x86_64

if [ "${NV_ARCH}" == "arm64" ]; then
  ARCH=sbsa
fi

wget "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/${ARCH}/${KEYRING}"
sudo dpkg --install "${KEYRING}"
sudo apt-get update

sudo apt-get -y install cuda-toolkit "cuda-drivers-${NV_DRIVER_VERSION}"

sudo dpkg --purge "${KEYRING}"
