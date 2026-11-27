---
id: ADR-SBC-0009
title: "Package repository: OPNsense series in the path, and pull-based publishing"
kind: adr
status: accepted
date: 2026-11-27
decided: 2026-11-27
deciders: [Kevin Adams]
supersedes: []
related: [ADR-SBC-0006, ADR-SBC-0005, ADR-SBC-0007, FR-SBC-PKG-0001]
---

# ADR-SBC-0009: Package repository: OPNsense series in the path, and pull-based publishing

> **In short:** Building the repository (#4) changed two details of
> ADR-SBC-0006. Packages now live under the OPNsense series as well as the
> FreeBSD ABI, like OPNsense's own repository. And plugin repos no longer
> push into the repository with a token: they publish GitHub releases, and
> the repository pulls them, so its signing key never leaves it.

This supersedes two bullets of ADR-SBC-0006's Decision, **Repo layout** and
the **publishing** half of "Built the freenas-proxmox way". The rest of
ADR-SBC-0006 still stands.

## Context

While building `TheGrandWazoo/opnsense-repo`:

1. OPNsense's own repository URL is `${ABI}/<series>/latest` (e.g.
   `FreeBSD:15:amd64/26.7/latest`), and the official vendor plugin
   `os-sunnyvalley` does the same with `%%PLUGIN_ABI%%`. Packages built for
   26.7 are linked against 26.7's PHP and OpenSSL; `${ABI}` alone does not
   change between OPNsense series on the same FreeBSD major, so a 27.1
   firewall could be offered 26.7 builds.
2. Pushing from os-SBC into another repo needs a long-lived token for that
   repo stored in os-SBC (a PAT or deploy key). It cannot be created from
   the API by automation, and it is one more secret that could leak.

## Decision

**Layout:** `https://thegrandwazoo.github.io/opnsense-repo/${ABI}/<series>/<track>/`,
for example `FreeBSD:15:amd64/26.7/devel`. The bootstrap package fills in
the series at build time (`%%PLUGIN_ABI%%`), so it always points at the
series it was built for.

**Publishing is pull, not push:**

- os-SBC's CI `publish` job, using only its own `GITHUB_TOKEN`, uploads the
  packages and a `manifest.json` (series, ABI, file names) to GitHub
  releases: a rolling `devel` release for `next`, and a release per
  `vX.Y.Z` tag.
- opnsense-repo's `publish` workflow runs every 30 minutes, on push, and by
  hand. It reads `sources.toml`, rebuilds the whole site from the public
  release assets, signs each track and pushes `gh-pages` only when
  something changed.
- Track mapping: `devel` release → `devel`; `vN.M.P-rc.K` → `vN/testing`;
  `vN.M.P` → `vN/stable` and `vN/testing`; a `deps` release → every track.
- Signing uses a `signing_command` (pkg-repo(8)), because only that writes
  the signature and public key into the catalogue in the form
  `signature_type: "fingerprints"` checks. Each publish verifies every track
  with pkg against the fingerprint shipped in `os-ksa-repo`, and fails if
  pkg reports any signature problem.

## Alternatives considered

- **`${ABI}/<track>` only (ADR-SBC-0006 as written).** Rejected for the
  reason in Context 1.
- **Push with a fine-grained token.** Faster (no polling delay), but adds a
  cross-repo secret. Can be added later on top of pull, as a
  `repository_dispatch` trigger, without changing the layout.

## Consequences

- Up to 30 minutes between a merge on `next` and the build appearing on the
  devel track. Publishing can be started by hand from opnsense-repo's
  Actions tab when that matters.
- A new OPNsense series needs a rebuild and a new bootstrap build; the old
  series' tracks stay published for firewalls not yet upgraded
  (RB-SBC-0001 step E).
- os-SBC's releases page now carries a `devel` pre-release whose tag moves
  with every merge to `next`. `v*` tags remain permanent (ruleset).
