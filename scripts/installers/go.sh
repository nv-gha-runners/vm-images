#!/bin/bash
set -euo pipefail

LATEST_GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n1)

GO_URL="https://dl.google.com/go/${LATEST_GO_VERSION}.linux-${NV_ARCH}.tar.gz"
GO_SHA_URL="${GO_URL}.sha256"

wget -q "${GO_URL}" "${GO_SHA_URL}"
diff --ignore-trailing-space <(sha256sum go*.tar.gz | awk '{ print $1; }') go*.tar.gz.sha256
sudo tar -C /usr/local -xzf go*.tar.gz

sudo sed -i '/^PATH=/ s|=\"|=\"/usr/local/go/bin:|' /etc/environment
PATH=$PATH:/usr/local/go/bin go version
sudo rm -rf go*.tar.gz*
