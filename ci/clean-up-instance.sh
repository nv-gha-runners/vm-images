#!/bin/bash
set -euo pipefail

INSTANCE_ID=$(
  aws ec2 describe-instances \
    --filters \
    "Name=tag:matrix-id,Values=${MATRIX_ID}" \
    "Name=tag:gh-run-id,Values=${GITHUB_RUN_ID}" \
    --query 'Reservations[*].Instances[*].InstanceId' --output text
)

if [ -z "${INSTANCE_ID}" ]; then
  echo "Instance not found. Exiting..."
  exit 0
fi

echo "Terminating instance..."
aws ec2 terminate-instances --instance-ids "${INSTANCE_ID}"
