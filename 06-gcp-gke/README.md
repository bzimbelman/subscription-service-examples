# 06 — GCP GKE

GKE deploy. The `values.yaml` overlays the engine chart with GCE ingress,
internal-LB MLLP, `standard-rwo` storage class, and Workload Identity for
Cloud SQL credentials.

## Prerequisites

- A GKE cluster (1.28+), Workload Identity enabled
- A Cloud SQL Postgres 15+ instance with private IP reachable from the
  cluster's VPC
- A reserved external (or internal) global IP for the ingress
- A `ManagedCertificate` covering the ingress host
- A Google Service Account (GSA) with `roles/secretmanager.secretAccessor`
  on the password secret, bound via Workload Identity to the KSA
- The engine chart on disk:
  ```bash
  git clone --depth=1 --branch v1.0.0 \
    https://github.com/example-org/subscription-service /tmp/engine
  ```

## Install

```bash
./install.sh \
  --set externalPostgres.host=10.x.y.z \
  --set serviceAccount.annotations."iam\.gke\.io/gcp-service-account"=subscription-service@my-project.iam.gserviceaccount.com \
  --set config.auth.issuer=https://idp.example.com/realms/main
```

## Verify

```bash
./verify.sh
```

## Diff from engine defaults

| Field | Default | This recipe |
|---|---|---|
| `ingress.className` | `nginx` | `gce` |
| `storage.storageClassName` | `standard` | `standard-rwo` |
| `mllp.service.type` | `ClusterIP` | `LoadBalancer` (internal) |
| `serviceAccount.annotations` | none | Workload Identity binding |

## Knobs to change before going live

- **Every `REPLACE_WITH_*` placeholder** in `values.yaml`
- **`storage.storageClassName: standard-rwo`** — bump to `premium-rwo`
  (pd-ssd) if matchbox cache or HAPI binary storage gets heavy
- **MLLP LB scope** — `Internal` keeps it on the VPC; restrict source CIDRs
  via firewall rules
- **`ManagedCertificate`** — provisioning can take 15-30 min; the verify
  script will fail until it's `Active`

## Tear down

```bash
helm uninstall subscription-service -n subscription-service
kubectl delete ns subscription-service
```
