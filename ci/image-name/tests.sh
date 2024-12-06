#!/bin/bash

set -euo pipefail

MATRIX="$(yq -o json matrix.yaml)"
MATRIX="${MATRIX}" jq --run-tests ci/image-name/deserialize.test

ci/image-name/deserialize.sh linux-gpu-565-open-amd64-pr-1234 | jq -e '. == {"os": "linux", "variant": "gpu", "driver_version": "565", "driver_flavor": "open", "arch": "amd64", "branch_name": "pr-1234"}'
