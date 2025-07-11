#!/usr/bin/env bash
#MISE description="Install Argo CD"
set -e

# Arguments
ENV=$1

# Check if environment variable is provided
if [ -z "$ENV" ]; then
  echo "Error: environment not specified"
  echo "Usage: mise run bootstrap <environment>"
  echo "Example: mise run bootstrap dev"
  exit 1
fi

# Variables
BOOTSTRAP_DIR="${ROOT_DIR}/bootstrap"
ARGOCD_DIR="${BOOTSTRAP_DIR}/argocd"

# Check if Argo CD is already installed
if helm list -n argocd | grep -q argocd; then
    echo "Argo CD is already installed."
    echo "Manage ArgoCD via GitOps repository."
    exit 0
fi

# Install Argo CD
echo "Installing Argo CD"
helm repo add argo-cd "$(yq e '.dependencies[0].repository' "${ARGOCD_DIR}/Chart.yaml")"
helm dependency update "${ARGOCD_DIR}"
helm secrets upgrade \
    --install \
    argocd \
    "${ARGOCD_DIR}" \
    --namespace argocd \
    --create-namespace \
    --values "${ARGOCD_DIR}/values.yaml" \
    --values "${ARGOCD_DIR}/values.enc.yaml" \
    --wait

# Update stringData.name in the Secret in bootstrap.yaml to the current environment
# Then apply the bootstrap.yaml
yq '
  (select(.kind == "Secret" and .metadata.name == "argocd-cluster-name")
    .stringData.name) = env(ENV)
' "${BOOTSTRAP_DIR}/bootstrap.yaml" | \
kubectl apply -f -
