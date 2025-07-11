#!/usr/bin/env bash
#MISE description="Terraform destroy"
#MISE alias="down"
set -e

# Arguments
ENV=$1

# Check if environment variable is provided
if [ -z "$1" ]; then
  echo "Error: environment not specified"
  echo "Usage: mise run destroy <environment>"
  echo "Example: mise run destroy dev"
  exit 1
fi

# Init
mise run terraform:init "${ENV}"

# Load environment variables
. "${ROOT_DIR}/.mise/tasks/.private/load-env-vars.sh" "${ENV}"

# Destroy
terraform \
  -chdir="${TERRAFORM_DIR}" \
    destroy \
      -var-file="${ROOT_DIR}/${ENV}.tfvars"