#!/usr/bin/env bash
# Smoke test: confirm strict channel security is rejecting bad endpoints.

set -euo pipefail

HAPI_BASE="${HAPI_BASE:-http://localhost:${HAPI_HOST_PORT:-18080}/fhir}"

step() { printf '\n==> %s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

step "HAPI reachable"
curl -fsS "${HAPI_BASE}/metadata" >/dev/null \
  || fail "HAPI not responding"

step "Reject http:// (must be https in strict mode)"
status=$(curl -s -o /tmp/strict-http.json -w '%{http_code}' -X POST \
  -H 'Content-Type: application/fhir+json' \
  --data-binary @- "${HAPI_BASE}/Subscription" <<'JSON'
{
  "resourceType": "Subscription",
  "status": "active",
  "reason": "verify strict mode rejects http",
  "criteria": "Patient?",
  "channel": {"type": "rest-hook", "endpoint": "http://hooks.example-downstream.test/"}
}
JSON
)
case "$status" in
  4*) echo "OK: HAPI rejected http endpoint ($status)";;
  *) fail "Expected 4xx for http:// endpoint, got $status";;
esac

step "Reject endpoint not on allowlist"
status=$(curl -s -o /tmp/strict-deny.json -w '%{http_code}' -X POST \
  -H 'Content-Type: application/fhir+json' \
  --data-binary @- "${HAPI_BASE}/Subscription" <<'JSON'
{
  "resourceType": "Subscription",
  "status": "active",
  "reason": "verify allowlist denies unknown host",
  "criteria": "Patient?",
  "channel": {"type": "rest-hook", "endpoint": "https://attacker.example.test/x"}
}
JSON
)
case "$status" in
  4*) echo "OK: HAPI rejected non-allowlisted endpoint ($status)";;
  *) fail "Expected 4xx for non-allowlisted endpoint, got $status";;
esac

step "Accept allowlisted https endpoint"
status=$(curl -s -o /tmp/strict-ok.json -w '%{http_code}' -X POST \
  -H 'Content-Type: application/fhir+json' \
  --data-binary @- "${HAPI_BASE}/Subscription" <<'JSON'
{
  "resourceType": "Subscription",
  "status": "active",
  "reason": "verify allowlisted endpoint is accepted",
  "criteria": "Patient?",
  "channel": {"type": "rest-hook", "endpoint": "https://hooks.example-downstream.test/incoming"}
}
JSON
)
case "$status" in
  2*) echo "OK: HAPI accepted allowlisted endpoint ($status)";;
  *) fail "Expected 2xx for allowlisted endpoint, got $status";;
esac

echo
echo "OK: strict channel security is enforcing as expected."
