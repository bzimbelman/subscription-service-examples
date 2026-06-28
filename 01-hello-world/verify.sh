#!/usr/bin/env bash
# verify.sh — idempotent smoke test for 01-hello-world.
#
# Exits 0 if HAPI is up, matchbox is reachable, the seed Subscription
# exists, and our sample Patient is queryable. Exits non-zero otherwise.
# Safe to run repeatedly.

set -euo pipefail

HAPI_BASE="${HAPI_BASE:-http://localhost:${HAPI_HOST_PORT:-18080}/fhir}"
MATCHBOX_BASE="${MATCHBOX_BASE:-http://localhost:${MATCHBOX_HOST_PORT:-18081}/matchbox}"

step() { printf '\n==> %s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

step "HAPI metadata endpoint"
curl -fsS "${HAPI_BASE}/metadata" >/dev/null \
  || fail "HAPI not responding at ${HAPI_BASE}/metadata"

step "Matchbox CapabilityStatement"
curl -fsS "${MATCHBOX_BASE}/fhir/metadata" >/dev/null \
  || fail "Matchbox not responding at ${MATCHBOX_BASE}/fhir/metadata"

step "Seed Subscription present"
body=$(curl -fsS "${HAPI_BASE}/Subscription?identifier=urn:example:subscription-service:examples|01-hello-world-patient-firehose")
echo "$body" | grep -q '"resourceType":"Bundle"' \
  || fail "Subscription search returned unexpected response"
echo "$body" | grep -q '"total":0' \
  && fail "Seed Subscription not present in HAPI yet (try: docker compose logs seed-subscription)"

step "Sample patient lookup"
# We don't require the sample patient to exist (the user may not have
# sent the MLLP yet); just verify the search endpoint responds.
curl -fsS "${HAPI_BASE}/Patient?identifier=MRN-EXAMPLE-001" >/dev/null \
  || fail "Patient search endpoint not responding"

echo
echo "OK: hello-world stack looks healthy."
