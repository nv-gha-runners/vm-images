#!/bin/bash
# This script computes the matrix for the GHAs matrix job.
set -euo pipefail


yq -o json \
  '.' \
  matrix.yaml | \
  jq -c 'include "ci/compute-matrix"; compute_matrix(.)'
