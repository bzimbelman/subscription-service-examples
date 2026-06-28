#!/usr/bin/env bash
# install.sh — install the engine chart on an EKS cluster with this values file.
#
# Assumes you've already:
#   - aws eks update-kubeconfig --name <cluster>
#   - installed AWS Load Balancer Controller, External Secrets Operator, EBS CSI
#   - created the IAM role for IRSA and the RDS instance
# and have the engine chart on disk (or in a chart repo).

set -euo pipefail

CHART="${CHART:-/tmp/engine/deploy/k8s/charts/subscription-service}"
RELEASE="${RELEASE:-subscription-service}"
NAMESPACE="${NAMESPACE:-subscription-service}"

if [ ! -d "$CHART" ]; then
  echo "ERROR: chart not found at $CHART"
  echo "  git clone --depth=1 --branch v1.0.0 https://github.com/example-org/subscription-service /tmp/engine"
  exit 1
fi

kubectl get ns "$NAMESPACE" >/dev/null 2>&1 \
  || kubectl create ns "$NAMESPACE"

helm upgrade --install "$RELEASE" "$CHART" \
  --namespace "$NAMESPACE" \
  --values values.yaml \
  --wait --timeout 10m \
  "$@"

echo
echo "Installed. Run ./verify.sh after the ALB has an address."
