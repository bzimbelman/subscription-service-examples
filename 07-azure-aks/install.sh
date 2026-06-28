#!/usr/bin/env bash
# install.sh — install the engine chart on an AKS cluster.

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
echo "Installed. Run ./verify.sh after AGIC has wired the ingress."
