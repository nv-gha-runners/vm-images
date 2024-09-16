#!/bin/bash
set -euo pipefail

KEYRING="/usr/share/keyrings/docker.gpg"
APT="/etc/apt/sources.list.d/docker.list"

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o "${KEYRING}"
sudo chmod a+r "${KEYRING}"

echo \
  "deb [arch=\"$(dpkg --print-architecture)\" signed-by=${KEYRING}] https://download.docker.com/linux/ubuntu \
  \"$(. /etc/os-release && echo "$VERSION_CODENAME")\" stable" | \
  sudo tee "${APT}"
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

# Add Docker mirror to daemon.json and buildkitd.toml
sudo mkdir -p /etc/docker /etc/buildkit
sudo cp "${NV_CONTEXT_DIR}/dockerd.json" /etc/docker/daemon.json
sudo cp "${NV_CONTEXT_DIR}/buildkitd.toml" /etc/buildkit/buildkitd.toml

# Set MTU for qemu env
# shellcheck disable=SC2002
if [ "${NV_RUNNER_ENV}" == "qemu" ]; then
  cat /etc/docker/daemon.json | jq '. + {"mtu": 1480}' | sudo tee /etc/docker/daemon.json
  cat /etc/docker/daemon.json | jq '. + {"default-network-opts": {"bridge": {"com.docker.network.driver.mtu": "1480"}}}' | sudo tee /etc/docker/daemon.json
fi

sudo systemctl restart docker
sudo docker info

# Ensure user is part of docker group
sudo groupadd docker -f
sudo usermod -aG docker "${USER}"

sudo rm -rf "${APT}" "${KEYRING}"
