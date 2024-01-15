#!/usr/bin/env bash

set -euo pipefail ${RUNNER_DEBUG:+-x}
export GH_DEBUG=${RUNNER_DEBUG:+1}

PR_URL=$1
DEPENDENCY_NAMES=$2
UPDATE_TYPE=${3//"version-update:semver-"/}

conf_file="dependabot-automerge-whitelist.conf"
conf_file_path="repository/.github/workflows/${conf_file}"
default_conf_file_url="https://raw.githubusercontent.com/hazelcast/dependabot-automerge/master/.github/workflows/default-${conf_file}"  # Replace with the actual URL

if [ ! -f "$conf_file_path" ]; then
   curl -sSf "$default_conf_file_url" > "$conf_file_path"
fi

UPDATE_TYPES="major minor patch"

filter_supported_update_types() {
  local maximum_update_type=$1
  local ignored_update_types=${UPDATE_TYPES%%$maximum_update_type*}
  local position=${#ignored_update_types}
  echo "${UPDATE_TYPES:$position}"
}

readarray -t whitelisted_dependencies <<<$(grep "\S" "$conf_file_path")

for dependency_entry in "${whitelisted_dependencies[@]}"; do
  read -r dependency_name dependency_update_type <<< "$dependency_entry"
  dependency_update_type="${dependency_update_type:-patch}"
  if [[ ! "$dependency_update_type" =~ ^(minor|major|patch)$ ]]; then
    echo "Error: Invalid update type for ${dependency_name}. It must be not set or be one of: $UPDATE_TYPES."
    exit 1
  fi
  allowed_update_types=$(filter_supported_update_types "$dependency_update_type")
  if [[ $DEPENDENCY_NAMES == *"$dependency_name"* && $allowed_update_types = *$UPDATE_TYPE*  ]]; then
    gh pr merge --auto --squash "$PR_URL"
    gh pr review --approve "$PR_URL"
    gh pr edit --add-assignee "@me" "$PR_URL"
    MSG="Automerging a whitelisted $UPDATE_TYPE update of $DEPENDENCY_NAMES"
    gh pr comment "$PR_URL" -b "$MSG"
    echo "$MSG"
    exit 0;
  fi
done

echo "Non-whitelisted $UPDATE_TYPE update of $DEPENDENCY_NAMES. Skipping"
