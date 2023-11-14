#!/bin/bash
set -euo pipefail


# Note: This package is installed from the official Ubuntu repository since
# their release assets (https://github.com/cli/cli/releases/latest) contain
# version numbers in the file names. Querying the API for the version number is
# an option, but unauthenticated requests could get rate limited
# (https://docs.github.com/en/rest/overview/resources-in-the-rest-api#rate-limiting).
# The repository is removed after the package is installed.
KEYRING=/usr/share/keyrings/githubcli-archive-keyring.gpg
APT=/etc/apt/sources.list.d/github-cli.list

curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of="${KEYRING}"

sudo chmod go+r "${KEYRING}"
echo "deb [arch=$(dpkg --print-architecture) signed-by=${KEYRING}] https://cli.github.com/packages stable main" | sudo tee "${APT}" > /dev/null
sudo apt update
sudo apt install gh -y

gh --version
sudo rm "${APT}" "${KEYRING}"
