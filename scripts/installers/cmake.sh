#!/bin/bash
set -euo pipefail

KEYRING=/usr/share/keyrings/kitware-archive-keyring.gpg
APT=/etc/apt/sources.list.d/kitware.list

wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null \
  | gpg --dearmor - \
  | sudo tee "${KEYRING}" >/dev/null

echo "deb [signed-by=${KEYRING}] https://apt.kitware.com/ubuntu/ jammy main" | sudo tee "${APT}" >/dev/null

sudo apt-get update
sudo apt install -y cmake

cmake --version
sudo rm -rf "${KEYRING}" "${APT}"
