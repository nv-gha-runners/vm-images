#!/bin/bash
# This script outputs the values in config.yaml for the environment specified by
# the `RUNNER_ENV` environment variable. The output is in the form of
# `KEY=VALUE` pairs, one per line. This allows the output to be injected as
# environment variables in GitHub Actions. It prefixes each value with `NV_` and
# uppercases the key. Here is an example when `RUNNER_ENV=aws`:
# NV_DOMAIN=arc-eks
# NV_PACKER_SOURCE=amazon-ebs
set -euo pipefail


yq -o json \
  '.[env(RUNNER_ENV)]' \
  config.yaml | \
  jq -r 'to_entries | .[] | "NV_\(.key|ascii_upcase)=\(.value)"'
