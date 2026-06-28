# 02 — multi-facility

Same stack as `01-hello-world`, but with multi-tenancy turned on. Each
request must declare a tenant (`X-Test-Tenant` in test mode, or a `tenant`
JWT claim in production). HAPI stores resources in partitioned tables, and
searches scoped to one tenant cannot see another tenant's data.

The engine's design lives in `docs/multi-tenancy.md` in the engine repo — this
recipe just shows the practical knobs.

## Prerequisites

Same as [`01-hello-world`](../01-hello-world/), plus a working `01` stand-up
to confirm your environment first.

## Deploy

```bash
cp ../01-hello-world/.env.example .env
docker compose --env-file .env up -d
```

## Verify

```bash
./verify.sh
```

The script creates a Patient under `facility-a` and confirms `facility-b`
cannot see it. If `verify.sh` exits 0, isolation is working.

## What changed vs. 01

A two-line config diff is the whole story:

```diff
-SUBSCRIPTION_SERVICE_MULTITENANCY=disabled
+SUBSCRIPTION_SERVICE_MULTITENANCY=enabled
+SUBSCRIPTION_SERVICE_MULTITENANCY_TEST_MODE=true     # for this recipe only
```

The interface engine also gains an `IPF_TENANT_MAP` so that MLLP messages
arriving with `MSH-4=EXAMPLE_FACILITY_A` get tagged with tenant `facility-a`
before they hit HAPI.

## Knobs to change before going live

- **`SUBSCRIPTION_SERVICE_MULTITENANCY_TEST_MODE=true`** — this opens a HUGE
  hole: anyone who can hit HAPI can claim any tenant via a header. Set to
  `false` and wire up real JWT auth (engine `docs/auth.md`) before exposing.
- **`IPF_TENANT_MAP`** — the example facility codes are placeholders. Map
  your real MSH-4 sending-facility values to internal tenant ids.
- **Per-tenant Subscriptions** — Subscriptions are now tenant-scoped. The
  seed Subscription from `01` will NOT fire across tenants. Plan for one
  Subscription per tenant per channel, or use a partition-aware delivery
  pattern (see engine `docs/multi-tenancy.md`).

## Tear down

```bash
docker compose down -v
```
