#!/bin/bash
set -euo pipefail

# Don't install CUDA Driver if NV_DRIVER_VERSION is not set
if [ "${NV_VARIANT}" != "gpu" ]; then
  echo "NV_VARIANT is not 'gpu'. Skipping NVIDIA Container Toolkit installation."
  exit 0
fi

KEYRING="/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg"
APT="/etc/apt/sources.list.d/nvidia-container-toolkit.list"

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o "${KEYRING}"
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed "s#deb https://#deb [signed-by=${KEYRING}] https://#g" | \
  sudo tee "${APT}"

sudo apt-get update

sudo apt-get install -y --no-install-recommends nvidia-container-toolkit-base

sudo rm -rf "${APT}" "${KEYRING}"

# Add nvidia runtime to docker and set as default
sudo nvidia-ctk runtime configure --runtime docker --set-as-default

# Enable CDI
sudo nvidia-ctk config --in-place --set nvidia-container-runtime.mode=cdi

# Add udev rule to generate CDI spec at boot
sudo cp "${NV_CONTEXT_DIR}/nvidia-cdi.rules" /lib/udev/rules.d/71-nvidia-cdi.rules

sudo systemctl restart docker
docker info
