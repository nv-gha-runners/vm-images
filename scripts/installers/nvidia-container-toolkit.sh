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

sudo apt-get install -y --no-install-recommends nvidia-container-toolkit

sudo rm -rf "${APT}" "${KEYRING}"

# Add Docker mirror to daemon.json
DOMAIN=$(yq '.[env(NV_RUNNER_ENV)].domain' "${NV_HELPER_SCRIPTS}/config.yaml")
export DOMAIN
cat "${NV_HELPER_SCRIPTS}/dockerd.gpu.json" | envsubst | sudo tee /etc/docker/daemon.json

sudo systemctl restart docker
docker info
