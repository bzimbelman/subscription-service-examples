#!/usr/bin/env bash
# Smoke test: pods Ready, readiness probe green via Traefik ingress.

set -euo pipefail

NAMESPACE="${NAMESPACE:-subscription-service}"
RELEASE="${RELEASE:-subscription-service}"
HOST="${HOST:-subscription-service.internal.example}"

step() { printf '\n==> %s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

step "All pods Ready"
kubectl -n "$NAMESPACE" wait --for=condition=Ready pods \
  -l "app.kubernetes.io/instance=$RELEASE" \
  --timeout=5m \
  || fail "pods never went Ready"

step "Readiness probe green via Traefik"
# We expect HOST to resolve internally (CoreDNS override, /etc/hosts, or a
# real A record). For ad-hoc verification, pass --resolve.
curl -fsS -k "https://${HOST}/actuator/health/readiness" \
  | grep -q '"status":"UP"' \
  || fail "readiness probe not UP at https://${HOST}/actuator/health/readiness"

step "MLLP LoadBalancer has an external IP"
mllp_ip=$(kubectl -n "$NAMESPACE" get svc -l app.kubernetes.io/component=mllp \
  -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
if [ -z "$mllp_ip" ]; then
  fail "MLLP service has no external IP; check MetalLB address pool"
fi
echo "MLLP available at ${mllp_ip}:2575"

echo
echo "OK: subscription-service is healthy on RKE2"
