#!/bin/bash
set -euo pipefail

# adapted from https://github.com/actions/runner-images/blob/81ef6f228d68d81f3db70b80551aace30e2675b9/images/linux/scripts/helpers/install.sh#L77-L97
get_github_latest_release_tag() {
  local REPO_ORG=$1
  local RESULTS_PER_PAGE="100"

  json=$(curl -fsSL "https://api.github.com/repos/${REPO_ORG}/releases?per_page=${RESULTS_PER_PAGE}")
  tagName=$(echo $json | jq -r '.[] | select((.prerelease==false) and (.assets | length > 0)).tag_name' | sort --unique --version-sort | egrep -v ".*-[a-z]|beta" | tail -1)

  echo "${tagName}"
}

get_github_latest_release_version() {
  local REPO_ORG=$1
  echo "$(get_github_latest_release_tag "${REPO_ORG}" | sed 's/[A-Za-z]//')"
}
