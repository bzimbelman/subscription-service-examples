# 01 — hello world

The smallest working subscription-service deploy. One Postgres, one HAPI, one
matchbox, one interface-engine. MLLP listener on `:2575` accepts HL7 v2,
matchbox transforms it to a FHIR Bundle, the Bundle lands in HAPI as a
Patient, a Subscription fires on every Patient create.

If this recipe doesn't work, no other recipe in this repo will. Start here.

## Prerequisites

- Docker 24+ with `docker compose` v2
- `curl`, `nc` (BSD or GNU netcat)
- About 4 GB free RAM (HAPI + Postgres + matchbox are the heavy ones)
- Ports `18080`, `18081`, `18090`, `2575` free on localhost (override in `.env`)

## Deploy

```bash
# 1. Configure (defaults are fine for most laptops)
cp .env.example .env

# 2. Bring it up. The seed-subscription sidecar exits after PUTting one
#    Subscription into HAPI; the rest of the services stay running.
docker compose --env-file .env up -d

# 3. Wait for healthy
docker compose ps
```

The first boot pulls images and runs Liquibase against an empty Postgres — give
it 60-90 seconds before the verify step.

## Send a message

```bash
# Send a synthetic ADT^A04 (new outpatient) over MLLP. The sample is
# obvious test data: Test Patient One, MRN-EXAMPLE-001, DOB 1900-01-01.
cat seed/sample.hl7 \
  | sed 's/$/\r/' \
  | (printf '\x0b'; cat; printf '\x1c\r') \
  | nc -q 1 localhost 2575
```

(The `printf` / `sed` dance wraps the message in MLLP framing — `<VT>...<FS><CR>`
— and converts to CRLF line endings, both of which the IPF MLLP endpoint
expects. If your `nc` doesn't support `-q`, drop it; some builds use `-w 1`
instead.)

## Verify

```bash
# The Patient should be queryable in HAPI within a few seconds. The
# interface-engine worker polls every second by default.
curl -s 'http://localhost:18080/fhir/Patient?identifier=MRN-EXAMPLE-001' \
  | jq '.entry[0].resource | {id, name, birthDate}'

# Expected:
# {
#   "id": "...",
#   "name": [{"family": "TestPatient", "given": ["One"], "prefix": ["Mr"]}],
#   "birthDate": "1900-01-01"
# }
```

Or run the full smoke test:

```bash
./verify.sh
```

## Inspect the Subscription

```bash
curl -s 'http://localhost:18080/fhir/Subscription?identifier=urn:example:subscription-service:examples|01-hello-world-patient-firehose' \
  | jq '.entry[0].resource'
```

The seed Subscription fires `rest-hook` to `http://host.docker.internal:8000/hello-webhook`
— a placeholder. Point a local listener at it (e.g. `python3 -m http.server 8000`)
to actually catch deliveries; otherwise HAPI will log delivery failures, which
is harmless for this recipe.

## Knobs to change before going live

- **`SUBSCRIPTION_SERVICE_CHANNEL_SECURITY=permissive`** — fine for localhost;
  switch to `strict` (see `03-secure-channels/`) before allowing arbitrary
  channel endpoints.
- **`SUBSCRIPTION_SERVICE_AUTH_ENABLED=false`** — anyone who can reach :18080
  can write FHIR resources. Wire up the engine's auth flow (engine docs
  `docs/auth.md`) before exposing this beyond localhost.
- **Postgres password `hapi`** — set a real one in `.env`.
- **`host.docker.internal` channel endpoint** — meaningful only on the host
  running compose; rewrite to a real reachable URL.

## Tear down

```bash
docker compose down -v
```

The `-v` drops the Postgres volume. Leave it out to keep the database
around for the next `up`.

## Next

- [`02-multi-facility/`](../02-multi-facility/) — turn on tenant isolation.
- Engine repo `docs/architecture.md` — what's actually happening end-to-end.
