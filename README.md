# subscription-service deployment recipes

This repo collects copy-and-edit recipes for deploying the
[subscription-service](https://github.com/example-org/subscription-service) engine
in a handful of common shapes. Each recipe is self-contained: a `README.md`
that walks through the deploy, an artifact directory (`docker-compose.yml`
or `values.yaml`), and a `verify.sh` smoke test.

The recipes are **starting points**, not turnkey production stacks. They are
intentionally small so the diffs are easy to read. Each one has a "knobs you'll
want to change before going live" section in its README.

## Which recipe should I start with?

| Want to... | Start here |
|---|---|
| See the thing work in 5 minutes on a laptop | [`01-hello-world/`](./01-hello-world/) |
| Run with tenant isolation (one engine, many sites) | [`02-multi-facility/`](./02-multi-facility/) |
| Tighten channel-endpoint policy (no `localhost`, signed webhooks, etc.) | [`03-secure-channels/`](./03-secure-channels/) |
| Run with no public internet (mirrored IGs, pinned images) | [`04-air-gapped/`](./04-air-gapped/) |
| Deploy to AWS EKS | [`05-aws-eks/`](./05-aws-eks/) |
| Deploy to GCP GKE | [`06-gcp-gke/`](./06-gcp-gke/) |
| Deploy to Azure AKS | [`07-azure-aks/`](./07-azure-aks/) |
| Deploy on-prem (Rancher / RKE2 on bare metal) | [`08-on-prem-rke/`](./08-on-prem-rke/) |

All recipes assume you have the engine's Helm chart available at
`deploy/k8s/charts/subscription-service/` in the engine repo, OR that you've
published the chart to a registry your cluster can pull from. The cloud
recipes (`05`-`08`) ship a `values.yaml` and an `install.sh` that points at
the engine repo's chart; the Compose recipes (`01`-`04`) reference the
engine repo's `deploy/docker/docker-compose.yml` and override what they need.

## Repo layout

```
.
|-- README.md                this file
|-- CONTRIBUTING.md          how to propose a new recipe
|-- SECURITY.md              vuln reporting
|-- LICENSE                  Apache 2.0
|-- .github/workflows/ci.yml lints all compose + helm values on PR
|-- 01-hello-world/          minimal MLLP-in, FHIR-out, one Subscription
|-- 02-multi-facility/       multi-tenancy on
|-- 03-secure-channels/      channel-security strict mode
|-- 04-air-gapped/           no internet, IGs preloaded
|-- 05-aws-eks/              AWS EKS values.yaml + install.sh
|-- 06-gcp-gke/              GCP GKE values.yaml + install.sh
|-- 07-azure-aks/            Azure AKS values.yaml + install.sh
`-- 08-on-prem-rke/          Rancher / RKE2 values.yaml + install.sh
```

## Synthetic data only

Every sample HL7 message, Patient resource, MRN, and name in this repo is
synthetic. Examples use obviously-fake values like `Test Patient One`,
`MRN-EXAMPLE-001`, and DOB `1900-01-01`. Do not commit real PHI here.

## License

Apache 2.0 — see [LICENSE](./LICENSE).
