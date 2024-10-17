#!/bin/bash

. setup_version.sh

setup_verion
echo "$PREFIX"

echo "prefix=$PREFIX" >> $GITHUB_OUTPUT
