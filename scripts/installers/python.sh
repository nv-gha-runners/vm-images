#!/bin/bash
set -euo pipefail

sudo apt update
sudo apt-get install -y --no-install-recommends \
  python3 \
  python3-dev \
  python3-pip \
  python3-venv


# Prepend $HOME/.local/bin /etc/environemnt PATH
# Adding this dir to PATH will make installed pip commands are immediately available.
sudo sed -i '/^PATH=/ s|=\"|=\"$HOME/.local/bin:|' /etc/environment
