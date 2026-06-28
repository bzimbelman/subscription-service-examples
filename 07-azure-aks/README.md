# 07 — Azure AKS

AKS deploy. The `values.yaml` overlays the engine chart with Application
Gateway ingress (AGIC), Azure Disk storage, internal LB for MLLP, and
Azure AD Workload Identity for Postgres credentials.

## Prerequisites

- An AKS cluster (1.28+) with:
  - Azure AD Workload Identity enabled
  - Application Gateway Ingress Controller (AGIC) add-on enabled, OR a
    standalone AGIC install
  - Secrets Store CSI driver + Azure Key Vault provider, OR external-secrets
- An Azure Database for PostgreSQL Flexible Server, private-endpoint
  attached to the AKS VNet
- A User-Assigned Managed Identity federated to the KSA, with KV
  `Secrets User` role on the password secret
- An Application Gateway with an SSL cert uploaded (referenced by name in
  the `appgw-ssl-certificate` annotation)
- The engine chart on disk:
  ```bash
  git clone --depth=1 --branch v1.0.0 \
    https://github.com/example-org/subscription-service /tmp/engine
  ```

## Install

```bash
./install.sh \
  --set externalPostgres.host=mypgflex.postgres.database.azure.com \
  --set serviceAccount.annotations."azure\.workload\.identity/client-id"=00000000-0000-0000-0000-000000000000 \
  --set config.auth.issuer=https://login.microsoftonline.com/<tenant>/v2.0
```

## Verify

```bash
./verify.sh
```

## Diff from engine defaults

| Field | Default | This recipe |
|---|---|---|
| `ingress.className` | `nginx` | `azure-application-gateway` |
| `storage.storageClassName` | `standard` | `managed-csi-premium` |
| `mllp.service.type` | `ClusterIP` | `LoadBalancer` (internal) |

## Knobs to change before going live

- **Every `REPLACE_WITH_*` placeholder** in `values.yaml`
- **`storage.storageClassName: managed-csi-premium`** — drop to
  `managed-csi` to save cost if matchbox cache pressure is low
- **MLLP internal LB subnet** — set to the dedicated MLLP subnet, not
  the cluster default
- **WAF on App Gateway** — recommend enabling WAF in Prevention mode in
  front of the FHIR REST endpoint

## Tear down

```bash
helm uninstall subscription-service -n subscription-service
kubectl delete ns subscription-service
```
