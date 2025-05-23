#!/usr/bin/env bash
#MISE description="Provision Talos cluster"
set -e

# Arguments
ENV=$1

# Check if environment variable is provided
if [ -z "$1" ]; then
  echo "Error: environment not specified"
  echo "Usage: mise run apply <environment>"
  echo "Example: mise run apply dev"
  exit 1
fi

# Verify that the environment file exists
if [ ! -f "${ENV}.tfvars" ]; then
  echo "Error: Environment file '${ENV}.tfvars' not found"
  exit 1
fi

mise run plan "${ENV}"
mise run apply "${ENV}"
mise run kubeconfig
mise run talosconfig