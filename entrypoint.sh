#!/bin/bash

set -eu

command -v splitsh-lite >/dev/null 2>&1 || {
    echo "$0 requires splitsh-lite but it's not installed.  Aborting." >&2
    exit 1
}

source_repository=https://github.com/vairogs/vairogs.git
source_branch=master

typeset -A components

while IFS== read -r path repo; do
    components["$path"]="$repo"
done < <(jq -r '.[] | .path + "=" + .repo ' /tmp/components.json)

for K in "${!components[@]}"; do
    temp_remote=${components[$K]//GH_TOKEN@/${GH_TOKEN}@}
    echo -e "\n${temp_remote}\n"
    # The rest shouldn't need changing.
    temp_repo=$(mktemp -d)
    # shellcheck disable=SC2002
    temp_branch=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 8 ; echo '')

    # Checkout the old repository, make it safe and checkout a temp branch
    git clone ${source_repository} "${temp_repo}"
    cd "${temp_repo}"
    git checkout "${source_branch}"
    git remote remove origin
    git checkout -b "${temp_branch}"

    sha1=$(splitsh-lite --prefix="${K}" 2>/dev/null)
    git reset --hard "${sha1}"
    git remote add remote "${temp_remote}"
    git push -u remote "${temp_branch}":"${source_branch}" --force
    git remote rm remote

    ## Cleanup
    cd /tmp
    rm -rf "${temp_repo}"
done
