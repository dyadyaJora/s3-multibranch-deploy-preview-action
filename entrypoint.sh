#!/bin/bash

function version {
    echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }';
}

function setup_verion {
    if [ ! -f version ]; then
        echo "Error: File 'version' does not exist."
        exit 1
    fi
    THIS_VERSION=$(cat version | sed s/^v//)
    THIS_VERSION_COMPARABLE=$(version $(cat version | sed s/^v//))
    LATEST_VERSION_COMPARABLE=$(version $(git describe --tags $(git rev-list --tags --max-count=1) | sed s/^v// 2> /dev/null || echo '0'))
    BRANCH_NAME=${GITHUB_REF#refs/heads/}
    SHA_SHORT=$(git rev-parse --short HEAD)
}

function replace_special_characters() {
    local input_string="$1";
    local replaced_string=$(echo "$input_string" | sed 's/[^a-zA-Z0-9]/_/g');
    echo "$replaced_string";
}

function deploy {
    # if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_REGION" ]; then
    #     echo "Error: AWS credentials are not set."
    #     exit 1
    # fi

    # aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
    # aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
    # aws configure set region "$AWS_REGION"

    if [ ! -d "$INPUT_FOLDER" ]; then
        echo "Error: Directory $INPUT_FOLDER does not exist. Nothing to deploy."
        exit 1
    fi
    escaped_branch_name=$(replace_special_characters "$BRANCH_NAME")
    date_prefix=$(date +%Y-%m-%d-%H-%M-%S_)
    S3_URL="s3://$INPUT_AWS_BUCKET/$escaped_branch_name/$date_prefix$SHA_SHORT/"
    echo "Uploading to $S3_URL"
    aws s3 sync $INPUT_FOLDER $S3_URL || exit 1

    preview_url="https://$INPUT_AWS_BUCKET.s3.amazonaws.com/$escaped_branch_name/$date_prefix$SHA_SHORT/index.html"
    echo "preview_url=$preview_url" >> $GITHUB_OUTPUT
}

function s3branchrotate {
    new_list=("$1")
    for b in $(cat $2); do
        [[ $b != "$1" ]] && new_list+=("$b")
    done;
    printf "%s\n" "${new_list[@]}" > $2
}

function cleanup_branch_folders() {
    echo "Cleanup branch folders"
    aws s3 cp s3://$INPUT_AWS_BUCKET/.branches .branches_old
    
    s3branchrotate $escaped_branch_name .branches_old

    lines_count=$(cat .branches_old | wc -l)
    last_branch=$(tail -1 .branches_old)
    head -$INPUT_MAX_BRANCH_DEPLOYED .branches_old > .branches
    aws s3 cp .branches s3://$INPUT_AWS_BUCKET/
    [ "$lines_count" -gt "$INPUT_MAX_BRANCH_DEPLOYED" ] && aws s3 rm --recursive s3://$INPUT_AWS_BUCKET/$last_branch/
}

function cleanup_commit_folders {
    echo "Cleanup commit folders"
    aws s3 ls s3://$INPUT_AWS_BUCKET/$escaped_branch_name/ | awk '$NF ~ /\/$/ { print $NF }' > .commit_versions
    cat .commit_versions  # Debug: print the versions

    oldest_version=$(head -1 .commit_versions)
    versions_count=$(cat .commit_versions | wc -l)
    echo "Oldest version: $oldest_version"
    echo "Versions count: $versions_count"

    if [ "$versions_count" -gt "$INPUT_MAX_COMMIT_PER_BRANCH_DEPLOYED" ]; then
        echo "Removing oldest version: $oldest_version"
        aws s3 rm --recursive s3://$INPUT_AWS_BUCKET/$escaped_branch_name/$oldest_version || echo "Error removing version"
    else
        echo "No need to remove versions."
    fi
}

echo "=== STARTING ==="
echo "GITHUB_REF: $GITHUB_REF"

echo "=== Setting up version ==="
setup_verion
echo "Branch: $BRANCH_NAME"

echo "=== Deploying ==="
deploy

echo "=== Cleanup branch folders ==="
cleanup_branch_folders

echo "=== Cleanup commit folders ==="
cleanup_commit_folders

echo " === FINISHED SUCCESSFULLY ==="
