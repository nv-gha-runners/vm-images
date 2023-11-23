#!/bin/bash
# This script cleans up the EC2 instance created by Packer.
set -euo pipefail

INSTANCE_ID=$(
  aws ec2 describe-instances \
    --filters \
    "Name=tag:image-name,Values=${NV_IMAGE_NAME}" \
    "Name=tag:gh-run-id,Values=${NV_RUN_ID}" \
    --query 'Reservations[*].Instances[*].InstanceId' --output text
)

if [ -z "${INSTANCE_ID}" ]; then
  echo "Instance not found. Exiting..."
  exit 0
fi

echo "Terminating instance..."
aws ec2 terminate-instances --instance-ids "${INSTANCE_ID}"
