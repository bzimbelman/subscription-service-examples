#!/usr/bin/env bash
# Smoke test: two tenants, isolated reads.
#
# Creates a Patient in tenant facility-a, then verifies that a search
# against tenant facility-b does NOT see it.

set -euo pipefail

HAPI_BASE="${HAPI_BASE:-http://localhost:${HAPI_HOST_PORT:-18080}/fhir}"

step() { printf '\n==> %s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

step "HAPI reachable"
curl -fsS "${HAPI_BASE}/metadata" >/dev/null \
  || fail "HAPI not responding"

step "Create Patient under facility-a"
curl -fsS -X POST -H 'Content-Type: application/fhir+json' \
  -H 'X-Test-Tenant: facility-a' \
  --data-binary @- "${HAPI_BASE}/Patient" >/dev/null <<'JSON'
{
  "resourceType": "Patient",
  "identifier": [{"system": "urn:example:mrn", "value": "MRN-EXAMPLE-A-001"}],
  "name": [{"family": "TestPatient", "given": ["FacilityA"]}],
  "birthDate": "1900-01-01"
}
JSON

step "facility-a sees it"
a=$(curl -fsS -H 'X-Test-Tenant: facility-a' \
  "${HAPI_BASE}/Patient?identifier=urn:example:mrn|MRN-EXAMPLE-A-001")
echo "$a" | grep -q '"total":0' \
  && fail "facility-a cannot see its own Patient"

step "facility-b is isolated"
b=$(curl -fsS -H 'X-Test-Tenant: facility-b' \
  "${HAPI_BASE}/Patient?identifier=urn:example:mrn|MRN-EXAMPLE-A-001")
echo "$b" | grep -q '"total":0' \
  || fail "TENANT LEAK: facility-b can see facility-a's Patient"

echo
echo "OK: tenant isolation working."
