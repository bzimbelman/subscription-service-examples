#!/usr/bin/env bash
# Smoke test: pods Ready, readiness probe green via the GCE ingress.

set -euo pipefail

NAMESPACE="${NAMESPACE:-subscription-service}"
RELEASE="${RELEASE:-subscription-service}"

step() { printf '\n==> %s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

step "All pods Ready"
kubectl -n "$NAMESPACE" wait --for=condition=Ready pods \
  -l "app.kubernetes.io/instance=$RELEASE" \
  --timeout=5m \
  || fail "pods never went Ready"

step "Readiness probe green via ingress"
ip=$(kubectl -n "$NAMESPACE" get ingress -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}')
if [ -z "$ip" ]; then
  fail "Ingress has no IP yet; GCE LB still provisioning?"
fi
curl -fsS --resolve "subscription-service.example.com:443:${ip}" \
  "https://subscription-service.example.com/actuator/health/readiness" \
  | grep -q '"status":"UP"' \
  || fail "readiness probe not UP"

echo
echo "OK: subscription-service is healthy on GKE (ingress IP ${ip})"
