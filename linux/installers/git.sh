#!/bin/bash
set -euo pipefail

GIT_REPO="ppa:git-core/ppa"

sudo add-apt-repository -y $GIT_REPO
sudo apt-get update
sudo apt-get -y install \
  git \
  git-ftp \
  git-lfs

# Git version 2.35.2 introduces security fix that breaks action\checkout https://github.com/actions/checkout/issues/760
cat <<EOF | sudo tee --append /etc/gitconfig
[safe]
        directory = *
EOF

git --version
sudo add-apt-repository --remove $GIT_REPO
