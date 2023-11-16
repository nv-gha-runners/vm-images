#!/bin/bash
set -euo pipefail

KEYRING="/usr/share/keyrings/docker.gpg"
APT="/etc/apt/sources.list.d/docker.list"

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o "${KEYRING}"
sudo chmod a+r "${KEYRING}"

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=${KEYRING}] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee "${APT}" > /dev/null
sudo apt-get update

sudo apt-get install --no-install-recommends \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin

# Install latest docker-compose from GitHub releases
COMPOSE_URL="https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(arch)"
CHECKSUM_URL="${COMPOSE_URL}.sha256"
wget -q "${COMPOSE_URL}" "${CHECKSUM_URL}"
sha256sum -c docker-compose-*.sha256
rm -rf docker-compose*.sha256
sudo mkdir -p /usr/libexec/docker/cli-plugins
chmod +x docker-compose*
sudo mv docker-compose* /usr/libexec/docker/cli-plugins/docker-compose

# Add Docker mirror to daemon.json
DOMAIN=$(yq '.[env(NV_RUNNER_ENV)].domain' "${NV_HELPER_SCRIPTS}/config.yaml")
export DOMAIN
cat "${NV_HELPER_SCRIPTS}/dockerd.cpu.json" | envsubst | sudo tee /etc/docker/daemon.json

# Docker daemon takes time to come up after installing
sudo systemctl restart docker
docker info

sudo rm -rf "${APT}" "${KEYRING}"
