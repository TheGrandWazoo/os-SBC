---
id: ADR-SBC-0007
title: "CI pipeline: lint, test, build, integrate, publish"
kind: adr
status: accepted
date: 2026-11-25
decided: 2026-11-26
deciders: [Kevin Adams]
supersedes: []
related: [ADR-SBC-0004, ADR-SBC-0005, ADR-SBC-0006, ADR-SBC-0010]
---

# ADR-SBC-0007: CI pipeline: lint, test, build, integrate, publish

> **In short:** Every pull request is linted, tested and built automatically. Heavy builds and real-call tests run on lab machines, and a manual call over the Flowroute test number gates each final release.

> **Partly superseded by ADR-SBC-0010 (2026-11-27):** the `deps` row. Kamailio
> and rtpproxy build on a GitHub-hosted FreeBSD VM against OPNsense's own
> packages; no self-hosted builder is needed. The rest of this ADR stands.

## Context

Everything that matters runs on FreeBSD/OPNsense, and GitHub's hosted runners
are Linux. Building Kamailio takes long and only needs to happen when its
version or the OPNsense series changes. The plugin itself (PHP, XML, Jinja
templates, shell, Python) is small and changes on every PR.

## Decision

One workflow, `ci.yml`, triggered on PRs to and pushes on `next` and
`release/*`, and on `v*` tags. Actions are pinned to commit SHAs, and
Dependabot updates them.

| Job | Runs on | What it does | Required check |
|---|---|---|---|
| `lint` | ubuntu (hosted) | `php -l` (PHP 8.5), phpcs PSR-12 (OPNsense style), `xmllint` on models/forms/menus/ACLs, shellcheck, ruff, actionlint, gitleaks, `tools/check_docs.py` | yes |
| `test` | ubuntu (hosted) | Render the configd Jinja templates with fixture configs using OPNsense's template engine; check the rendered Kamailio config with `kamailio -c` (6.1 in a container); Python unit tests | yes |
| `build` | FreeBSD 15.1 VM on a hosted runner | Check out opnsense/plugins at the matching branch, place the plugin at `net/sbc`, run `make package`, upload the `.pkg` | yes |
| `deps` | self-hosted FreeBSD 15.1 builder (lab Proxmox VM) | poudriere with the opnsense/ports tree and OPNsense's make.conf for the target series; builds Kamailio, rtpproxy and missing libraries | no (manual, or when the version file changes) |
| `integration` | self-hosted, OPNsense VM on lab Proxmox | Install from the devel repo; SIPp scenarios: register through, inbound and outbound call with media, BYE releases the relay ports, flood rejected | not on PRs; required before a release tag |
| `publish` | ubuntu (hosted), `publish` environment | Sign and update the repo track for the branch or tag (ADR-SBC-0005) | n/a |

A manual **carrier test** (`workflow_dispatch`, self-hosted runner) installs the
testing track on the second physical OPNsense firewall and places real calls
over the Flowroute test trunk. It is required before a final `vN.M.P` tag,
never on PRs. Flowroute credentials live only in a protected environment.

## Alternatives considered

- **Build everything on hosted FreeBSD VMs.** Fine for the plugin. Too slow and
  too fragile for poudriere builds of Kamailio on every run.
- **Skip the Linux lint and test jobs and do it all on FreeBSD.** Slower
  feedback for the 90 % of changes that are PHP, XML and templates.

## Consequences

- Needs a self-hosted FreeBSD builder and an OPNsense test VM in the lab.
  Packer templates (as in freenas-proxmox-packer) would make them reproducible.
- The `test` job depends on vendoring or fetching OPNsense's template engine
  module; pin it to the OPNsense series under test.
- Required-check names must match branch protection exactly (ADR-SBC-0004).
