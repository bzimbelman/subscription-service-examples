# Governance

This document describes how decisions are made in this project and how the project is organized.

## Project scope

This repository is the **deployment-examples catalog** for the bzonfhir subscription-service: end-to-end recipes that show how to run the engine on different platforms (hello-world, multi-facility, secure channels, air-gapped, AWS EKS, GCP GKE, Azure AKS, on-prem RKE2). The engine and the rest of the project live in companion repos. The same governance model applies across all of them.

## Maintainership

Today the project has a **single maintainer**: Brian Zimbelman ([@bzimbelman](https://github.com/bzimbelman)). The maintainer is the final decision-maker on:

- What examples are accepted into `main`.
- The shape of the recipe directories (per-platform layout, what files are required).
- Release timing.
- The published roadmap.

Single-maintainer governance is intentional at this stage. Responses may be slower than a multi-maintainer project — please be patient.

## Planned scale-up

When sustained external contribution arrives — concretely, when at least three external contributors have each landed three or more substantive PRs over a 90-day window — the maintainer will propose a **steering committee** to take over governance of this repo and the companions. The committee will be a small group (three to five members) chartered to:

- Resolve technical disputes the maintainer cannot resolve alone.
- Approve material changes to the recipe layout convention.
- Add and remove committee members.
- Update this document.

The steering-committee bylaws will be drafted at that time and published as a follow-up to this file. Until then, the maintainer makes those calls.

## Decision-making in the meantime

For day-to-day decisions:

- **Accepting a recipe**: the maintainer reviews, requests changes if needed, and merges when CI is green.
- **Rejecting a recipe**: the maintainer says no with a reason. Common reasons: drifts from the established per-platform layout, missing tests / smoke verification, hard-codes secrets, depends on a private cluster.
- **Disagreement**: open a GitHub Discussion on the [engine repo](https://github.com/bzimbelman/subscription-service/discussions). The maintainer will respond. If you still disagree, you are welcome to fork.

## Contribution sign-off (DCO, not CLA)

All commits MUST be signed off under the [Developer Certificate of Origin](https://developercertificate.org/):

```bash
git commit -s -m "your message"
```

The `-s` flag appends a `Signed-off-by:` trailer to the commit, which is your assertion that you have the right to contribute the code under the project's license (Apache 2.0).

We do **not** use a Contributor License Agreement. The DCO + Apache 2.0 combination keeps the contribution path simple: no separate paperwork, no clickwrap, no corporate signatory required.

DCO enforcement on pull requests is provided by the [DCO GitHub App](https://github.com/apps/dco). The app installation is an org-level setting; the maintainer is responsible for keeping it installed for this repository. The per-repo config lives in `.github/dco.yml`.

## Code of conduct

All participation in this project is subject to the [Code of Conduct](CODE_OF_CONDUCT.md) (Contributor Covenant v2.1). The maintainer enforces it.

## Security

Security issues should be reported privately via the repository's Security Advisory page, or by opening a minimal public issue requesting a private contact channel. Do **not** file a public issue containing exploit detail. See `SECURITY.md` when present.

## Licensing

Code is Apache 2.0. Documentation is CC BY 4.0 unless a directory says otherwise. By submitting a contribution you agree it is licensed under the same terms as the surrounding file.

## Amending this document

Today: the maintainer amends this file by PR-and-merge. After the steering committee stands up: changes require a majority vote of the committee, recorded in the PR conversation.
