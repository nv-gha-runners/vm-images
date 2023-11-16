#!/bin/bash
set -euo pipefail

source "${NV_HELPER_SCRIPTS}/github.sh"

ARCH_STRING=x64

if [ "${NV_ARCH}" == "arm64" ]; then
    ARCH_STRING=arm64
fi

PKG="https://github.com/actions/runner/releases/download/v${NV_RUNNER_VERSION}/actions-runner-linux-${ARCH_STRING}-${NV_RUNNER_VERSION}.tar.gz"
RUNNER_DIR="/opt/runner"

wget -q "${PKG}" -O actions-runner.tar.gz
sudo mkdir -p "${RUNNER_DIR}"
sudo tar -C "${RUNNER_DIR}" -xzf actions-runner.tar.gz
sudo chown -R "$(id --user):$(id --group)" "${RUNNER_DIR}"
sudo "${RUNNER_DIR}/bin/installdependencies.sh"
rm -rf ./actions-runner.tar.gz

# TODO: install runner service
