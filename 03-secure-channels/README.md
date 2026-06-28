# 03 — secure channels

Turns on `SUBSCRIPTION_SERVICE_CHANNEL_SECURITY=strict`. This recipe is the
opposite of `01-hello-world`'s `permissive`: HAPI now refuses to create a
Subscription whose channel endpoint is `http://` (must be https), is on
private / loopback ranges, or is not on the configured allowlist. Webhook
deliveries are HMAC-signed.

The engine's full channel-security design is in `docs/architecture.md` in
the engine repo, under "Channel security". This recipe shows the config.

## Prerequisites

Same as [`01-hello-world`](../01-hello-world/). You'll also want `openssl`
to generate the HMAC secret.

## Deploy

```bash
cp .env.example .env
# Generate a real HMAC secret:
sed -i.bak "s|replace-me-with-an-openssl-rand-hex-32-value|$(openssl rand -hex 32)|" .env
# Bring over the base settings from 01:
cat ../01-hello-world/.env.example >> .env

docker compose --env-file .env up -d
```

## Verify

```bash
./verify.sh
```

The script tries three Subscription creates — one with `http://`, one with a
non-allowlisted host, and one allowlisted https — and confirms only the
third is accepted.

## What changed vs. 01

```diff
-SUBSCRIPTION_SERVICE_CHANNEL_SECURITY=permissive
+SUBSCRIPTION_SERVICE_CHANNEL_SECURITY=strict
+SUBSCRIPTION_SERVICE_CHANNEL_ALLOWLIST=https://hooks.example-downstream.test/*,...
+SUBSCRIPTION_SERVICE_CHANNEL_HMAC_SECRET=<32-byte hex>
```

Webhook deliveries now include:

```
POST /incoming HTTP/1.1
Content-Type: application/fhir+json
X-Subscription-Service-Signature: sha256=<hex of HMAC-SHA256(body, secret)>
```

The downstream is expected to recompute the HMAC and reject the request on
mismatch.

## Knobs to change before going live

- **`SUBSCRIPTION_SERVICE_CHANNEL_ALLOWLIST`** — the example hostnames are
  obvious test values. Replace with your real downstreams.
- **`CHANNEL_HMAC_SECRET`** — generate fresh, store in a Secret manager, do
  NOT commit. Rotate periodically.
- **Subscription `endpoint` schemes** — `websocket` and `email` channels
  have their own strict-mode rules (TLS-only for both); see engine docs.
- **Egress firewall** — strict mode rejects RFC1918 / loopback by default
  but it is still a defense-in-depth layer. Run egress through an explicit
  proxy or firewall rule in production.

## Tear down

```bash
docker compose down -v
```
