#!/bin/bash

function setup_verion {
    # if [ ! -f version ]; then
    #     echo "Error: File 'version' does not exist."
    #     exit 1
    # fi
    # THIS_VERSION=$(cat version | sed s/^v//)
    # THIS_VERSION_COMPARABLE=$(version $(cat version | sed s/^v//))
    # LATEST_VERSION_COMPARABLE=$(version $(git describe --tags $(git rev-list --tags --max-count=1) | sed s/^v// 2> /dev/null || echo '0'))
    if [ ! -z $INPUT_PREFIX ]; then
        # todo: validate prefix
        echo "Using prefix: $INPUT_PREFIX"
        PREFIX=$INPUT_PREFIX
        return
    fi
    echo "Generating prefix"
    BRANCH_NAME=${GITHUB_REF#refs/heads/}
    SHA_SHORT=$(git rev-parse --short HEAD)
    escaped_branch_name=$(replace_special_characters "$BRANCH_NAME")
    date_prefix=$(date +%Y-%m-%d-%H-%M-%S_)
    PREFIX=$escaped_branch_name/$date_prefix$SHA_SHORT
}


function replace_special_characters() {
    local input_string="$1";
    local replaced_string=$(echo "$input_string" | sed 's/[^a-zA-Z0-9]/_/g');
    echo "$replaced_string";
}