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

VECTOR_CONFIG_DIR="/etc/vector"

# Clean default config
sudo rm -rf "${VECTOR_CONFIG_DIR}"/*

echo "VECTOR_CONFIG_YAML=${VECTOR_CONFIG_DIR}/*.yaml" | sudo tee /etc/default/vector
sudo cp "${NV_CONTEXT_DIR}/vector/common.yaml" "${VECTOR_CONFIG_DIR}/common.yaml"

if [ -d "${NV_CONTEXT_DIR}/vector/${NV_RUNNER_ENV}" ]; then
  sudo cp -r "${NV_CONTEXT_DIR}/vector/${NV_RUNNER_ENV}"/* "${VECTOR_CONFIG_DIR}/"
fi

sudo rm -rf "${APT}" "${KEYRING}"
