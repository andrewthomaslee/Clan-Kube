#!/usr/bin/env bash

set -e

# Assign arguments to variables.
REMOTE_OVERRIDE="$1"

# Initialize variables.
REMOTE="hel-m-0"
KUBECONFIG_PATH="$HOME/.kube/config"
PORT="6443"
SERVICE="rke2-api"

# Override the default remote if the second argument is provided.
if [ -n "$REMOTE_OVERRIDE" ]; then
    echo "==> Default remote '$REMOTE' overridden."
    REMOTE="$REMOTE_OVERRIDE"
fi

echo "==> Setting up kubeconfig for environment: $ENV"
echo "==> Using remote host: $REMOTE"

# Create the .kube directory if it doesn't already exist.
mkdir -p "$HOME/.kube"

# Fetch the rke2.yaml file from the remote server.
echo "==> Fetching rke2.yaml from $REMOTE..."
rsync "root@$REMOTE:/etc/rancher/rke2/rke2.yaml" "$KUBECONFIG_PATH"

# Exit if the rsync command failed.
if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch rke2.yaml from $REMOTE. Please check your connection and permissions."
    exit 1
fi

# Replace the default server address (https://[::1]:6443) with the load balancer and the environment-specific port.
echo "==> Setting server address to https://$SERVICE:$PORT..."
kubectl --kubeconfig="$KUBECONFIG_PATH" config set-cluster default --server="https://$SERVICE:$PORT"

echo "==> Done! Kubeconfig saved to $KUBECONFIG_PATH"