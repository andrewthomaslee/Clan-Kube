#!/usr/bin/env bash

set -e

# Check for the correct number of arguments.
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: get-k3s-token.sh <environment>"
    echo "Usage: get-k3s-token.sh <environment> [remote_override]"
    exit 1
fi

# Assign arguments to variables.
ENV="$1"
REMOTE_OVERRIDE="$2"

# Initialize variables.
REMOTE=""
TOKEN_PATH="$HOME/.kube/tokens"

# Determine settings based on the specified environment.
case "$ENV" in
  dev)
    REMOTE="hel-d-m"
    ;;
  prod)
    REMOTE="hel-p-m"
    ;;
  *)
    echo "Error: Invalid environment specified. Use 'dev' or 'prod'."
    exit 1
    ;;
esac

# Override the default remote if the second argument is provided.
if [ -n "$REMOTE_OVERRIDE" ]; then
    echo "==> Default remote '$REMOTE' overridden."
    REMOTE="$REMOTE_OVERRIDE"
fi

echo "==> Fetching K3s Token from: $REMOTE"

# Create the directory if it doesn't exist
mkdir -p $TOKEN_PATH

# Use the REMOTE variable to rsync
rsync root@$REMOTE:/var/lib/rancher/k3s/server/token $TOKEN_PATH/$REMOTE

echo "==> Token:"
echo "$(cat $TOKEN_PATH/$REMOTE)"