#!/bin/bash
set -euo pipefail

cat "${NV_HELPER_SCRIPTS}/nvme.sh" | envsubst '$NV_RUNNER_ENV' | sudo tee /nvme.sh
sudo chmod +x /nvme.sh
sudo cp "${NV_HELPER_SCRIPTS}/nvme.service" /etc/systemd/system/
sudo systemctl enable nvme.service
