#!/bin/bash

set -euo pipefail

KEYRING="/usr/share/keyrings/vector.gpg"
APT="/etc/apt/sources.list.d/vector.list"
APT_GPG_KEYS=(
  "DATADOG_APT_KEY_CURRENT.public"
  "DATADOG_APT_KEY_C0962C7D.public"
  "DATADOG_APT_KEY_F14F620E.public"
)

for key in "${APT_GPG_KEYS[@]}"; do
  curl "https://keys.datadoghq.com/${key}" | sudo gpg --import --batch --no-default-keyring --keyring "${KEYRING}"
done
sudo chmod a+r "${KEYRING}"

echo "deb [signed-by=${KEYRING}] \
      https://apt.vector.dev/ stable vector-0" | \
      sudo tee "${APT}"
sudo apt-get update

sudo apt-get install --no-install-recommends -y vector

sudo rm -rf "${APT}" "${KEYRING}"
sudo systemctl stop vector
sudo systemctl enable vector

# Make sure hostname is set before starting vector
sudo sed -i '/^After=/ s/$/ systemd-hostnamed.service/' /lib/systemd/system/vector.service

VECTOR_CONFIG_DIR="/etc/vector"

# Clean default config
sudo rm -rf "${VECTOR_CONFIG_DIR}"/*

# Copy env specific config
sudo cp "${NV_CONTEXT_DIR}/vector/${NV_RUNNER_ENV}-${NV_VARIANT}.yaml" "${VECTOR_CONFIG_DIR}/vector.yaml"

if [ "${NV_VARIANT}" == "gpu" ]; then
  sudo cp "${NV_CONTEXT_DIR}/vector/dcgm-exporter.service" /etc/systemd/system/dcgm-exporter.service
  sudo systemctl enable dcgm-exporter
fi
