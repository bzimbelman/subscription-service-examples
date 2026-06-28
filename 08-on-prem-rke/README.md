# 08 — On-prem (Rancher / RKE2)

Bare-metal deploy on Rancher RKE2. Uses RKE2's defaults where they fit
(Traefik ingress, `local-path` storage class) and MetalLB for the MLLP
`LoadBalancer` service.

## Prerequisites

- An RKE2 cluster (1.28+), Rancher-managed or stand-alone
- MetalLB installed with at least one address pool covering the IP you
  want the MLLP service to use (or replace with `kube-vip` / similar)
- A TLS cert and key for the ingress host (cert-manager + internal CA is
  the typical pattern; pre-create the Secret named in `tls.secretName`)
- An internal DNS A record for the ingress host
- The engine chart on disk:
  ```bash
  git clone --depth=1 --branch v1.0.0 \
    https://github.com/example-org/subscription-service /tmp/engine
  ```

## Install

```bash
# Pre-create the TLS Secret (cert-manager handles this automatically if
# you've wired it up; otherwise drop in your cert + key by hand).
kubectl -n subscription-service create secret tls subscription-service-tls \
  --cert=/path/to/tls.crt --key=/path/to/tls.key

./install.sh \
  --set ingress.hosts[0].host=subscription-service.your-domain.local \
  --set config.auth.issuer=https://idp.your-domain.local/realms/main
```

## Verify

```bash
./verify.sh
```

If the host isn't in DNS yet, pass `HOST=<ingress-ip>` and add
`--resolve` to the curl in `verify.sh`, OR just check pods Ready and the
MLLP LoadBalancer IP.

## Diff from engine defaults

| Field | Default | This recipe |
|---|---|---|
| `ingress.className` | `nginx` | `traefik` |
| `storage.storageClassName` | `standard` | `local-path` |
| `postgres.enabled` | `true` | `true` (kept in-cluster on bare metal) |
| `mllp.service.type` | `ClusterIP` | `LoadBalancer` (MetalLB) |

## Knobs to change before going live

- **`storage.storageClassName: local-path`** — fine for single-node /
  experimental setups but **does NOT survive node loss**. For HA, switch
  to Longhorn (`longhorn`) or Rook-Ceph (`rook-ceph-block`).
- **In-cluster Postgres** — `postgres.enabled: true` runs a single Postgres
  pod on `local-path`. For HA, swap in a Postgres operator (Zalando,
  CloudNativePG) and point `externalPostgres.host` at it.
- **MetalLB address pool name** — `subscription-service-pool` is the
  example; use the pool you actually created.
- **TLS cert** — pre-create the Secret or wire cert-manager. Self-signed
  works for testing; use an internal CA for production.

## Tear down

```bash
helm uninstall subscription-service -n subscription-service
kubectl delete ns subscription-service
```
