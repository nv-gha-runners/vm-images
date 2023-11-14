#!/bin/bash
set -euo pipefail

curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n -o ~/n
sudo bash ~/n lts

# fix global modules installation as regular user
# related issue https://github.com/actions/runner-images/issues/3727
sudo chmod -R 777 /usr/local/lib/node_modules
sudo chmod -R 777 /usr/local/bin

node --version
rm -rf ~/n
