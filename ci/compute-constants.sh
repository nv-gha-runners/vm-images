#!/bin/bash
# A script that computes the constants for our GHAs workflows
set -euo pipefail

# Compute the matrix
MATRIX=$(ci/compute-matrix.sh)

# Compute the timestamp
export TZ='America/New_York'
TIMESTAMP=$(date +'%Y%m%d%H%M%S')

# Compute the regions
DEFAULT_REGION=$(yq '.default_region' regions.yaml)
BACKUP_REGIONS=$(yq '.backup_regions | join(",")' regions.yaml)
PUBLIC_ECR_REGION=$(yq '.public_ecr_region' regions.yaml)

cat <<EOF | tee --append "${GITHUB_OUTPUT:-/dev/null}"
MATRIX=${MATRIX}
TIMESTAMP=${TIMESTAMP}
DEFAULT_AWS_REGION=${DEFAULT_REGION}
BACKUP_AWS_REGIONS=${BACKUP_REGIONS}
PUBLIC_ECR_REGION=${PUBLIC_ECR_REGION}
EOF
