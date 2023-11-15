#!/bin/bash
set -euo pipefail

source "${NV_HELPER_SCRIPTS}/github.sh"

LATEST_VERSION=$(get_github_latest_release_version "KitWare/CMake")
CHECKSUM="https://github.com/Kitware/CMake/releases/download/v${LATEST_VERSION}/cmake-${LATEST_VERSION}-SHA-256.txt"
PKG="https://github.com/Kitware/CMake/releases/download/v${LATEST_VERSION}/cmake-${LATEST_VERSION}-linux-$(arch).tar.gz"

wget -q "${PKG}" "${CHECKSUM}"

grep "^$(sha256sum cmake-*.tar.gz)$" cmake-*-SHA-256.txt
sudo tar --strip-components=1 -C /usr/local -xzf cmake-*.tar.gz
cmake --version
sudo rm -rf ./cmake-*
