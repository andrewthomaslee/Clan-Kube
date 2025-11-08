#!/usr/bin/env bash

set -e

# Check for the correct number of arguments.
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: get-kube-config.sh <environment>"
    echo "Usage: get-kube-config.sh <environment> [remote_override]"
    exit 1
fi

# Assign arguments to variables.
ENV="$1"
REMOTE_OVERRIDE="$2"

# Initialize variables.
REMOTE=""
KUBECONFIG_PATH=""
PORT=""

# Determine settings based on the specified environment.
case "$ENV" in
  dev)
    SERVICE="k3s-dev"
    REMOTE="hel-d-m"
    KUBECONFIG_PATH="$HOME/.kube/dev"
    PORT="6443"
    ;;
  prod)
    SERVICE="k3s-prod"
    REMOTE="hel-p-m"
    KUBECONFIG_PATH="$HOME/.kube/prod"
    PORT="6443"
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

echo "==> Setting up kubeconfig for environment: $ENV"
echo "==> Using remote host: $REMOTE"

# Create the .kube directory if it doesn't already exist.
mkdir -p "$HOME/.kube"

# Fetch the k3s.yaml file from the remote server.
echo "==> Fetching k3s.yaml from $REMOTE..."
rsync "root@$REMOTE:/etc/rancher/k3s/k3s.yaml" "$KUBECONFIG_PATH"

# Exit if the rsync command failed.
if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch k3s.yaml from $REMOTE. Please check your connection and permissions."
    exit 1
fi

# Replace the default server address (https://127.0.0.1:6443) with the load balancer and the environment-specific port.
echo "==> Setting server address to https://$SERVICE:$PORT..."
sed -i.bak "s|https://127.0.0.1:6443|https://$SERVICE:$PORT|g" "$KUBECONFIG_PATH"

echo "==> Done! Kubeconfig saved to $KUBECONFIG_PATH and configured for the '$ENV' environment."