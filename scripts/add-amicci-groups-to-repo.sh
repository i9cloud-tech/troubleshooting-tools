#!/bin/bash
set +x

main() {
  ARCH_TEAM=arch
  AMICCI_TEAM=amicci
  REPO=$1

  add_groups_to_repo $REPO $ARCH_TEAM maintain
  add_groups_to_repo $REPO $AMICCI_TEAM push
}

add_groups_to_repo() {
  local repo=$1
  local team=$2
  local permission=$3

  gh api -X PUT \
    /orgs/amicci-labs/teams/$team/repos/amicci-labs/$repo \
    -f permission=$permission | jq
  echo "Added $team team to $repo with $permission permission"
}

main "$@"
