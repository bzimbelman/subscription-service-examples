# Security policy

## Reporting a vulnerability

These recipes are example configurations, not a hosted service. If you find a
security issue in a recipe (e.g. a misconfigured default that would expose
secrets, a sample channel endpoint that would leak data, a sample auth flow
that's actually broken), please open a private security advisory on GitHub
or email the maintainers listed in the engine repo's `SECURITY.md`.

## Reporting a vulnerability in the engine

Recipes are downstream of the
[subscription-service](https://github.com/example-org/subscription-service)
engine. Vulnerabilities in the engine itself (HAPI auth, channel
dispatch, multi-tenancy isolation, etc.) should be reported to the engine
repo's security contacts, not here.

## Synthetic data

The example HL7 messages, Patient resources, MRNs, and configurations in
this repo are synthetic and obviously fake (`Test Patient One`,
`MRN-EXAMPLE-001`). Do not file a "PII leak" against examples that contain
clearly-synthetic data; do file one if you spot anything that looks real.
