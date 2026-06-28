# 05 — AWS EKS

Production-shaped deploy onto AWS EKS. The `values.yaml` here is a thin
overlay on the engine chart's defaults — only the fields that are
EKS-specific (ALB ingress, NLB for MLLP, EBS storage class, IRSA, RDS via
External Secrets) are set.

## Prerequisites

- An EKS cluster (1.28+), kubectl context pointed at it
- Cluster add-ons installed:
  - AWS Load Balancer Controller (ALB / NLB)
  - EBS CSI driver
  - External Secrets Operator (for RDS password from Secrets Manager)
- An RDS Postgres 15+ instance reachable from the cluster
- An IAM role with the policy listed below, configured for IRSA
- An ACM certificate ARN for the ALB
- The engine Helm chart on disk:
  ```bash
  git clone --depth=1 --branch v1.0.0 \
    https://github.com/example-org/subscription-service /tmp/engine
  ```

## IAM (IRSA)

The service-account needs minimal AWS permissions — only Secrets Manager
read (for the RDS password) by default. If you turn on AuditEvent export
to S3 or Kinesis, add those scopes.

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["secretsmanager:GetSecretValue"],
    "Resource": "arn:aws:secretsmanager:REGION:ACCOUNT:secret:hapi-rds-credentials-*"
  }]
}
```

Replace the `REPLACE_WITH_IAM_ROLE_ARN`, `REPLACE_WITH_ACM_CERT_ARN`,
`REPLACE_WITH_RDS_WRITER_ENDPOINT`, and `REPLACE_WITH_OIDC_ISSUER_URL`
placeholders in `values.yaml` before installing — or override via `--set`
flags in `install.sh`.

## Install

```bash
./install.sh \
  --set externalPostgres.host=my-rds.cluster-xxxx.us-east-1.rds.amazonaws.com \
  --set ingress.annotations."alb\.ingress\.kubernetes\.io/certificate-arn"=arn:aws:acm:... \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=arn:aws:iam::...:role/subscription-service \
  --set config.auth.issuer=https://idp.example.com/realms/main
```

## Verify

```bash
./verify.sh
```

Waits for pods Ready, finds the ingress hostname, and probes
`/actuator/health/readiness` over HTTPS.

## Diff from engine defaults

| Field | Default | This recipe |
|---|---|---|
| `postgres.enabled` | `true` (in-cluster) | `false` (use RDS) |
| `externalPostgres.enabled` | `false` | `true` |
| `storage.storageClassName` | `standard` | `gp3` |
| `ingress.className` | `nginx` | `alb` |
| `hapi.replicas` | `1` | `3` |
| `mllp.service.type` | `ClusterIP` | `LoadBalancer` (NLB) |

## Knobs to change before going live

- **Every `REPLACE_WITH_*` placeholder** in `values.yaml`
- **`hapi.resources`** — sized for ~50 msg/s sustained; tune to your
  expected load
- **`ingress.alb.ingress.kubernetes.io/scheme: internal`** — flip to
  `internet-facing` only if this really should be public
- **MLLP NLB** — restrict via `service.beta.kubernetes.io/load-balancer-source-ranges`
  to your upstream HL7 sender CIDRs

## Tear down

```bash
helm uninstall subscription-service -n subscription-service
kubectl delete ns subscription-service
```

RDS, IAM roles, ACM certs are not touched by the chart — clean those up
separately.
