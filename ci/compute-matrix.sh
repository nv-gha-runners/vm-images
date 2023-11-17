#!/bin/bash
set -euo pipefail

# This script computes the matrix for the GHAs matrix job. The values in
# config.yaml are injected into each matrix entry according to its `ENV` key.

yq -o json \
  eval-all \
  '{"matrix": select(filename == "matrix.yaml")} + {"config": select(filename == "config.yaml")}' \
  matrix.yaml config.yaml | \
  jq -c 'include "ci/compute-matrix"; compute_matrix(.matrix; .config)'
