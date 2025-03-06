#!/bin/bash

set -euo pipefail

# Currently vector is not used on AWS
if [ "${NV_RUNNER_ENV}" != "qemu" ]; then
  echo "NV_RUNNER_ENV is not 'qemu'. Skipping Vector installation."
  exit 0
fi

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
sudo systemctl enable vector

sudo rm -rf "${APT}" "${KEYRING}"

VECTOR_CONFIG_DIR="/etc/vector"

# Clean default config
sudo rm -rf "${VECTOR_CONFIG_DIR}"/*

# Copy env specific config
sudo cp "${NV_CONTEXT_DIR}/vector/${NV_RUNNER_ENV}-${NV_VARIANT}.yaml" "${VECTOR_CONFIG_DIR}/vector.yaml"

if [ "${NV_VARIANT}" == "gpu" ]; then
  sudo cp "${NV_CONTEXT_DIR}/vector/dcgm-exporter.service" /etc/systemd/system/dcgm-exporter.service
  sudo systemctl enable dcgm-exporter
fi
