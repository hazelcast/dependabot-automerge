#!/usr/bin/env bash

set -euo pipefail ${RUNNER_DEBUG:+-x}
export GH_DEBUG=${RUNNER_DEBUG:+1}

PR_URL=$1
DEPENDENCY_NAMES=$2
UPDATE_TYPE=$3

conf_file="dependabot-automerge-whitelist.conf"
conf_file_path=".github/workflows/${conf_file}"
default_conf_file_url="https://raw.githubusercontent.com/hazelcast/dependabot-automerge/master/.github/workflows/${conf_file}"  # Replace with the actual URL

if [ ! -f "$conf_file_path" ]; then
   curl -sSf "$default_conf_file_url" > "$conf_file_path"
fi

# Read whitelisted dependencies into an array
readarray -t whitelisted_dependencies < "$conf_file_path"

for dependency in "${whitelisted_dependencies[@]}"; do
  if [[ $DEPENDENCY_NAMES == *"$dependency"* && "$UPDATE_TYPE" == 'version-update:semver-patch' ]]; then
    gh pr merge --auto --squash "$PR_URL"
    gh pr comment "$PR_URL" -b "Auto-merging a whitelisted patch update."
    exit 0
  fi
done