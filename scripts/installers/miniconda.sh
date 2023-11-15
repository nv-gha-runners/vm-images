#!/bin/bash
set -euo pipefail

curl -fsSL https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-$(arch).sh -o miniforge.sh
chmod +x miniforge.sh
sudo ./miniforge.sh -b -p /usr/share/miniforge

CONDA=/usr/share/miniforge
echo "CONDA=$CONDA" | sudo tee --append /etc/environment

sudo ln -s $CONDA/bin/conda /usr/bin/conda

conda --version
sudo rm -rf miniforge.sh
