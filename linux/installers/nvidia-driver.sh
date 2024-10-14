#!/bin/bash
set -euo pipefail

# Don't install CUDA Driver if NV_DRIVER_VERSION is not set
if [ "${NV_VARIANT}" != "gpu" ]; then
  echo "NV_VARIANT is not 'gpu'. Skipping CUDA Driver installation."
  exit 0
fi

KEYRING=cuda-keyring_1.1-1_all.deb
ARCH=x86_64

if [ "${NV_ARCH}" == "arm64" ]; then
  ARCH=sbsa
fi

wget -q "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/${ARCH}/${KEYRING}"
sudo dpkg --install "${KEYRING}"
sudo apt-get update

sudo apt-get -y install "nvidia-driver-${NV_DRIVER_VERSION}-server-open"

sudo dpkg --purge "$(dpkg -f "${KEYRING}" Package)"

# Set nvidia kernel module params
sudo sh -c "cat <<EOF > /etc/modprobe.d/nvidia.conf
options nvidia NVreg_NvLinkDisable=1
options nvidia NVreg_OpenRmEnableUnsupportedGpus=1
EOF"
sudo update-initramfs -u

# Set persistence mode on
OVERRIDE_DIR="/etc/systemd/system/nvidia-persistenced.service.d"
sudo mkdir -p "${OVERRIDE_DIR}"
sudo cp "${NV_CONTEXT_DIR}/nvidia-persistenced-override.conf" "${OVERRIDE_DIR}/override.conf"
