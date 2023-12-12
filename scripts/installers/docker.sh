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
DOMAIN=$(yq '.[env(NV_RUNNER_ENV)].domain' "${NV_HELPER_SCRIPTS}/config.yaml")
export DOMAIN
envsubst < "${NV_HELPER_SCRIPTS}/dockerd.cpu.json" | sudo tee /etc/docker/daemon.json
envsubst < "${NV_HELPER_SCRIPTS}/buildkitd.toml" | sudo tee /etc/buildkit/buildkitd.toml

sudo systemctl restart docker
docker info

sudo rm -rf "${APT}" "${KEYRING}"
