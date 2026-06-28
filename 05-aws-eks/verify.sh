#!/usr/bin/env bash
# Smoke test: pods Ready, readiness probe green via the ALB.

set -euo pipefail

NAMESPACE="${NAMESPACE:-subscription-service}"
RELEASE="${RELEASE:-subscription-service}"

step() { printf '\n==> %s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

step "All pods Ready"
kubectl -n "$NAMESPACE" wait --for=condition=Ready pods \
  -l "app.kubernetes.io/instance=$RELEASE" \
  --timeout=5m \
  || fail "pods never went Ready; check kubectl -n $NAMESPACE get pods"

step "Readiness probe green"
host=$(kubectl -n "$NAMESPACE" get ingress -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}')
if [ -z "$host" ]; then
  fail "Ingress has no hostname yet; ALB still provisioning?"
fi
curl -fsS "https://${host}/actuator/health/readiness" \
  | grep -q '"status":"UP"' \
  || fail "readiness probe not UP at https://${host}/actuator/health/readiness"

echo
echo "OK: subscription-service is healthy on EKS at https://${host}"
