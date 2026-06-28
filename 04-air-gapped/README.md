# 04 — air-gapped

Deploys the engine in an environment with no public-internet egress. The
two practical changes are:

1. **Images come from an internal registry**, pinned by digest. The
   compose override uses placeholder digests — replace with the digests of
   your mirrored images.
2. **IG tarballs are preloaded** into `./igs/` and HAPI is told to skip
   the online fetch from `packages.fhir.org`.

Everything else is the same shape as `01-hello-world`. Multi-tenancy,
channel-security, and auth toggles are orthogonal — layer them on by
adding the relevant compose overrides on top.

## Prerequisites

- An internal Docker registry hosting:
  - `subscription-service/hapi`
  - `subscription-service/interface-engine`
  - `ahdis/matchbox`
  - `postgres:16-alpine`
- The IG tarballs (see [igs/README.md](./igs/README.md)) for which the
  engine is configured.

## Deploy

```bash
# 1. Preload IGs (one-time, on a connected box; transfer to air-gapped)
ls igs/*.tgz   # confirm tarballs are present

# 2. Replace the `0000...` image digests in docker-compose.yml with the
#    real digests from your internal registry.

# 3. Stand up
docker compose up -d
```

## Verify

```bash
./verify.sh
```

The script confirms HAPI is up and at least one ImplementationGuide is
loaded. A grep through `docker compose logs hapi` for
`packages.fhir.org` should come up empty.

## What changed vs. 01

- Every `image:` is pinned to `registry.internal.example/...@sha256:...`
- `SUBSCRIPTION_SERVICE_IG_OFFLINE=true` + `SUBSCRIPTION_SERVICE_IG_LOCAL_DIR=/igs`
- `MATCHBOX_OFFLINE=true` + `MATCHBOX_IG_LOCAL_DIR=/igs`

## Knobs to change before going live

- **Image digests** — the `0000...` placeholders in `docker-compose.yml`
  are not real digests. Replace with the digests your registry returns.
- **`registry.internal.example`** — your real internal registry hostname.
- **IG versions** — keep `./igs/` in sync with what the engine's
  `application.yaml` requests. A mismatch surfaces as a startup error in
  HAPI ("IG not found").
- **Egress firewall** — even with this config, run with an explicit deny
  on outbound DNS / HTTP from the HAPI and matchbox containers.

## Tear down

```bash
docker compose down -v
```
