#!/usr/bin/env bash

set -e

# Assign arguments to variables.
REMOTE_OVERRIDE="$1"

# Initialize variables.
REMOTE="hel-m-0"
TOKEN_PATH="$HOME/.kube/tokens"

# Override the default remote if the second argument is provided.
if [ -n "$REMOTE_OVERRIDE" ]; then
    echo "==> Default remote '$REMOTE' overridden."
    REMOTE="$REMOTE_OVERRIDE"
fi

echo "==> Fetching rke2 Token from: $REMOTE"

# Create the directory if it doesn't exist
mkdir -p $TOKEN_PATH

# Use the REMOTE variable to rsync
rsync root@$REMOTE:/var/lib/rancher/rke2/server/token $TOKEN_PATH/$REMOTE

echo "==> Token:"
echo "$(cat $TOKEN_PATH/$REMOTE)"