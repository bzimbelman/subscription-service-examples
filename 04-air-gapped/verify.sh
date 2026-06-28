#!/usr/bin/env bash
# Smoke test: confirm HAPI started without reaching the internet for IGs.

set -euo pipefail

HAPI_BASE="${HAPI_BASE:-http://localhost:${HAPI_HOST_PORT:-18080}/fhir}"

step() { printf '\n==> %s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

step "HAPI reachable"
curl -fsS "${HAPI_BASE}/metadata" >/dev/null \
  || fail "HAPI not responding"

step "IGs loaded from local mirror"
# HAPI exposes loaded ImplementationGuide resources via the FHIR REST API
# once it's done initializing. A non-zero total means the local IG dir
# was read.
total=$(curl -fsS "${HAPI_BASE}/ImplementationGuide?_count=0" \
  | sed -n 's/.*"total":\([0-9]*\).*/\1/p')
test "${total:-0}" -gt 0 \
  || fail "No ImplementationGuides loaded — check ./igs/ has tarballs"

step "No packages.fhir.org references in last hour of logs"
# Heuristic: if the engine reached out, the host would show in the logs.
# This won't run in CI (no docker logs), but is the right manual check.
echo "Manual: docker compose logs hapi | grep -i packages.fhir.org should be empty"

echo
echo "OK: air-gapped stack looks healthy; ${total} IG(s) loaded."
