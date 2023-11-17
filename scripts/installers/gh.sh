#!/bin/bash
set -euo pipefail

source "${NV_HELPER_SCRIPTS}/github.sh"

LATEST_VERSION=$(get_github_latest_release_version "cli/cli")
CHECKSUM="https://github.com/cli/cli/releases/download/v${LATEST_VERSION}/gh_${LATEST_VERSION}_checksums.txt"
PKG="https://github.com/cli/cli/releases/download/v${LATEST_VERSION}/gh_${LATEST_VERSION}_linux_${NV_ARCH}.deb"

wget -q "${PKG}" "${CHECKSUM}"

grep "^$(sha256sum gh_*.deb)$" gh_*_checksums.txt
sudo apt install ./gh_*.deb
gh --version
sudo rm -rf ./gh_*
