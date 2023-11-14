#!/bin/bash
set -euo pipefail

# Install Miniconda
curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$(arch).sh -o miniconda.sh
chmod +x miniconda.sh
sudo ./miniconda.sh -b -p /usr/share/miniconda

CONDA=/usr/share/miniconda
echo "CONDA=$CONDA" | sudo tee --append /etc/environment

sudo ln -s $CONDA/bin/conda /usr/bin/conda

conda --version
sudo rm -rf miniconda.sh
