#!/bin/bash

read -p "GitHub Org: " ORG
read -p "GitHub Repo: " REPO
read -s -p "GitHub Token: " TOKEN

echo ""
echo "Querying API"
echo ""

RUNNER_ID="local-test-runner"

curl -L \
  -X DELETE \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/$ORG/$REPO/runners/$RUNNER_ID

curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/$ORG/$REPO/actions/runners/generate-jitconfig \
  -d "{\"name\":\"$RUNNER_ID\",\"runner_group_id\":1,\"labels\":[\"self-hosted\",\"X64\",\"Windows\"],\"work_folder\":\"_work\"}"
