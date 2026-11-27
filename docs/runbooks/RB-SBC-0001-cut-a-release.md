---
id: RB-SBC-0001
title: "Cut a release"
kind: runbook
status: active
date: 2026-11-26
owners: [Kevin Adams]
related: [ADR-SBC-0004, ADR-SBC-0005, ADR-SBC-0009]
---

# RB-SBC-0001: Cut a release

> **In short:** Step by step: cut a release branch, ship release candidates and final releases, patch an existing line, and rebuild for a new OPNsense series.

Applies ADR-SBC-0004 (branches) and ADR-SBC-0005 (versions and channels). Docs and
issue closures happen **before** the tag, as in freenas-proxmox RUNBOOK-002.

## A. New major: cut `release/N.x` (first time for N.0.0)

1. Every issue in the `N.0.0` milestone is closed or moved.
2. On `next`: `CHANGELOG.md`, README support matrix and docs are current.
3. Create the branch from `next`:
   ```bash
   git fetch origin
   git push origin origin/next:refs/heads/release/N.x
   ```
4. Apply branch protection to `release/N.x` (same rules as `next`).
5. PR into `release/N.x`: remove `PLUGIN_DEVEL=yes` from `Makefile`, set
   `PLUGIN_VERSION=N.0.0`.
6. PR into `next`: bump `PLUGIN_VERSION` to the next planned version
   (e.g. `N.1.0`), keep `PLUGIN_DEVEL=yes`.
7. Add `vN/testing` and `vN/stable` to `tracks` in opnsense-repo's `sources.toml`, and a
   `KSA` entry for `vN/stable` to its bootstrap `KSA.conf` (ADR-SBC-0009).

## B. Release candidate

1. Integration suite green on the OPNsense lab VM.
2. Tag on `release/N.x`: `git tag -s vN.M.P-rc.K -m "os-sbc vN.M.P-rc.K"` and push.
3. CI creates the GitHub release; opnsense-repo picks it up into `vN/testing`
   within 30 minutes (or run its publish workflow by hand). Install on a lab box from that track and smoke test.

## C. Final release

1. Same commit as the last good RC, or a later fix-only commit.
2. Tag `vN.M.P` on `release/N.x` and push. CI publishes to `vN/stable`.
3. Write the GitHub release: supported OPNsense series, bundled Kamailio and
   rtpproxy versions, changes, upgrade notes.
4. Close the milestone. Close issues with version, SHA and doc pointers.
5. Move items to **Resolved** in `ROADMAP.md`.

## D. Patch release on an existing line

1. Fix merged to `next`, backported to `release/N.x` (CONTRIBUTING.md).
2. PR into `release/N.x`: bump `PLUGIN_VERSION` to `N.M.(P+1)`, update CHANGELOG.
3. Continue at step B or C.

## E. New OPNsense series (e.g. 27.1)

1. Rebuild Kamailio, rtpproxy and libraries with the `deps` job for the new series.
2. Run the integration suite on the new OPNsense version.
3. Publish under the new `${ABI}` if it changed, update the README support matrix.
