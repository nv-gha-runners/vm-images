#!/bin/bash
set -euo pipefail

# This script computes the matrix for the GHAs matrix job.

yq -o json \
  '.' \
  matrix.yaml | \
  jq -c 'include "ci/compute-matrix"; compute_matrix(.)'
