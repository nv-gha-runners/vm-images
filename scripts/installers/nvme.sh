#!/bin/bash
set -euo pipefail

# shellcheck disable=SC2016
envsubst '$NV_RUNNER_ENV' < "${NV_HELPER_SCRIPTS}/nvme.sh" | sudo tee /nvme.sh
sudo chmod +x /nvme.sh
sudo cp "${NV_HELPER_SCRIPTS}/nvme.service" /etc/systemd/system/
sudo systemctl enable nvme.service
