# Preloaded IG tarballs

Drop the IG `.tgz` files HAPI/matchbox need into this directory before
`docker compose up -d`. The minimum set for the engine's default profile:

- `hl7.fhir.us.core-7.0.0.tgz`
- `hl7.fhir.uv.subscriptions-backport-1.2.0.tgz`

Versions should match what the engine repo declares in
`hapi/config/application.yaml` (`subscription-service.igs.packages`).

To mirror from `packages.fhir.org` once (on a connected machine) and
transfer to the air-gapped host:

```bash
for pkg in \
  "hl7.fhir.us.core-7.0.0" \
  "hl7.fhir.uv.subscriptions-backport-1.2.0"
do
  name="${pkg%-*}"
  ver="${pkg##*-}"
  curl -fsSL "https://packages.fhir.org/${name}/${ver}" -o "${pkg}.tgz"
done
```

Then `scp *.tgz` to the air-gapped host and drop them here.

This directory is gitignored except for this README so we never accidentally
commit a multi-megabyte tarball.
