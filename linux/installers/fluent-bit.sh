#!/bin/bash

set -euo pipefail

# qemu env is now using vector
if [ "${NV_RUNNER_ENV}" == "qemu" ]; then
  echo "NV_RUNNER_ENV is 'qemu'. Skipping Fluent Bit installation."
  exit 0
fi

KEYRING="/usr/share/keyrings/fluentbit.gpg"
APT="/etc/apt/sources.list.d/fluentbit.list"

curl https://packages.fluentbit.io/fluentbit.key | sudo gpg --dearmor -o "${KEYRING}"
sudo chmod a+r "${KEYRING}"

CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")

echo \
  "deb [signed-by=${KEYRING}] \
  https://packages.fluentbit.io/ubuntu/${CODENAME} ${CODENAME} main" | \
  sudo tee "${APT}"
sudo apt-get update

sudo apt-get install --no-install-recommends -y fluent-bit
sudo systemctl enable fluent-bit

FLUENTBIT_CONFD="/etc/fluent-bit/conf.d"
sudo mkdir -p "${FLUENTBIT_CONFD}"

sudo cp "${NV_CONTEXT_DIR}/fluent-bit/fluent-bit.conf" /etc/fluent-bit/fluent-bit.conf
sudo cp "${NV_CONTEXT_DIR}/fluent-bit/common.conf" "${FLUENTBIT_CONFD}/common.conf"

if [ -d "${NV_CONTEXT_DIR}/fluent-bit/${NV_RUNNER_ENV}" ]; then
  sudo cp -r "${NV_CONTEXT_DIR}/fluent-bit/${NV_RUNNER_ENV}"/* "${FLUENTBIT_CONFD}/"
fi

sudo systemctl restart fluent-bit

sudo rm -rf "${APT}" "${KEYRING}"
