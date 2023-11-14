#!/bin/bash
set -euo pipefail

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
  | sh -s -- -y --default-toolchain=stable --profile=minimal
source "${HOME}/.cargo/env"

# TODO: These take forever to compile/install. Determine whether we want to keep
# them or drop them. If we keep them, we might want to consider adding more CPU/memory
# resources to increase compile speed.
#
# Install common tools
# rustup component add rustfmt clippy
# cargo install bindgen-cli cbindgen cargo-audit cargo-outdated
# Cleanup Cargo cache
# rm -rf "${HOME}/.cargo/registry/"*

# Prepend $HOME/.cargo/bin /etc/environemnt PATH
sudo sed -i '/^PATH=/ s|=\"|=\"$HOME/.cargo/bin:|' /etc/environment
