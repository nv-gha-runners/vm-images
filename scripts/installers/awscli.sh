#!/bin/bash
set -euo pipefail

curl -s "https://awscli.amazonaws.com/awscli-exe-linux-$(arch).zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install

aws --version
sudo rm -rf ./aws*
