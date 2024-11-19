#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")/../.."

MATRIX="$(yq -o json matrix.yaml)" IMAGE_NAME="$1" jq -c -n 'include "ci/image-name/deserialize"; env.IMAGE_NAME | deserialize_image_name'
