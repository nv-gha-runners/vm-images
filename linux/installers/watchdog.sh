#!/bin/bash
set -euo pipefail

# Watchdog is only for qemu and amd64 images
if [ "${NV_RUNNER_ENV}" != "qemu" ] || [ "${NV_ARCH}" == "arm64" ]; then
  exit 0
fi

# Install watchdog kernel modules and package
# --allow-change-held-packages is required as kernel packages are marked as hold
sudo apt install --no-install-recommends -y --allow-change-held-packages \
  "linux-modules-extra-$(uname -r)" \
  watchdog

# Configure watchdog daemon
sudo sed -i 's/#watchdog-device/watchdog-device/g' /etc/watchdog.conf
sudo sed -i 's/#log-dir/log-dir/g' /etc/watchdog.conf
sudo sed -i 's/run_watchdog=.*/run_watchdog=1/g' /etc/default/watchdog
sudo sed -i 's/watchdog_module=".*"/watchdog_module="i6300esb"/g' /etc/default/watchdog

# Enable watchdog daemon
sudo systemctl enable watchdog
