#!/bin/bash
set -euo pipefail

echo 'APT::Update::Error-Mode "any";' | sudo tee /etc/apt/apt.conf.d/warnings-as-errors

# Prevent kernel upgrades
sudo apt-mark hold \
  linux-{aws,generic,virtual} \
  linux-headers-{aws,generic,virtual} \
  linux-image-{aws,generic,virtual}
sudo apt-mark hold "$(uname -r)"

sudo apt update
sudo apt upgrade -y

sudo apt install -y \
  apt-transport-https \
  build-essential \
  ca-certificates \
  curl \
  gnupg \
  gpg \
  sudo \
  unzip \
  wget \
  zip

# Disable unattended-upgrades
sudo systemctl disable --now unattended-upgrades apt-daily.service apt-daily.timer apt-daily-upgrade.service apt-daily-upgrade.timer
echo 'APT::Periodic::Update-Package-Lists "0";' | sudo tee /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::Unattended-Upgrade "0";' | sudo tee -a /etc/apt/apt.conf.d/20auto-upgrades

# Disable snap auto refresh
sudo snap refresh --hold
