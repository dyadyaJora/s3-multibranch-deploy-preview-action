#!/bin/bash
ls -la

. $GITHUB_ACTION_PATH/setup_version.sh

setup_verion
echo "$PREFIX"

echo "prefix=$PREFIX" >> $GITHUB_OUTPUT
