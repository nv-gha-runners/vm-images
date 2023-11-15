#!/bin/bash
set -euo pipefail

echo 'APT::Update::Error-Mode "any";' | sudo tee /etc/apt/apt.conf.d/warnings-as-errors

sudo apt update
sudo apt upgrade -y

sudo apt install -y \
  build-essential \
  ca-certificates \
  curl \
  gnupg \
  gpg \
  sudo \
  unzip \
  wget \
  zip
