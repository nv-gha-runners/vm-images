#!/bin/bash
set -euo pipefail

source "${NV_CONTEXT_DIR}/github.sh"

ARCH_STRING=x64

if [ "${NV_ARCH}" == "arm64" ]; then
    ARCH_STRING=arm64
fi

PKG="https://github.com/actions/runner/releases/download/v${NV_RUNNER_VERSION}/actions-runner-linux-${ARCH_STRING}-${NV_RUNNER_VERSION}.tar.gz"
RUNNER_DIR="/home/runner"

# Download runner
wget -q "${PKG}" -O actions-runner.tar.gz
tar -C "${RUNNER_DIR}" -xzf actions-runner.tar.gz
sudo "${RUNNER_DIR}/bin/installdependencies.sh"
rm -rf ./actions-runner.tar.gz

# Copy scripts and services
sudo cp "${NV_CONTEXT_DIR}/runner.sh" /runner.sh
sudo cp "${NV_CONTEXT_DIR}/initialize_runner.sh" /home/runner/.initialize_runner.sh

_UID=$(id -u)
_GID=$(id -g)
sudo chown -R "${_UID}:${_GID}" /runner.sh
chmod +x /runner.sh

sudo cp "${NV_CONTEXT_DIR}/runner.service" /etc/systemd/system/
sudo systemctl enable runner.service
