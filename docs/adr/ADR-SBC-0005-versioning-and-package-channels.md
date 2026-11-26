# ADR-SBC-0005: Versioning and package channels

**Date**: 2026-11-25
**Status**: Proposed
**Deciders**: Kevin Adams
**Related**: ADR-SBC-0004, ADR-SBC-0006

## Context

The 2019 Makefile says `PLUGIN_VERSION=0.1` and was never released. OPNsense
plugins support two package flavours from the same source: `os-<name>`, and
`os-<name>-devel` when the Makefile sets `PLUGIN_DEVEL=yes`. OPNsense uses that
pair to offer development builds alongside stable ones in the plugin list.

freenas-proxmox learned (issue #271, ADR-010) that a single update channel
silently moves users across a major version. OPNsense's firmware update would
do the same with `os-sbc` 1.x to 2.x.

## Decision

- **Semantic versioning**, independent of OPNsense, Kamailio and rtpproxy
  versions. Supported versions of those are documented in the README support
  matrix and in release notes.
- **The first release is 1.0.0.** The Asterisk 0.x line was never released and
  ends as tag `v0.1.0-asterisk`.
- The version lives in one place: `PLUGIN_VERSION` in `Makefile`.
  `PLUGIN_REVISION` changes only for packaging-only rebuilds.
- **Channels:**

| Source | Package | Repo track | Version example |
|---|---|---|---|
| `next` (every merge) | `os-sbc-devel` | `devel` | `1.1.0` with revision = CI run number |
| `vN.M.P-rc.K` tag on `release/N.x` | `os-sbc` | `vN/testing` | `1.0.0.rc1` (must sort below `1.0.0`; see Consequences) |
| `vN.M.P` tag on `release/N.x` | `os-sbc` | `vN/stable` | `1.0.0` |

- **Majors are isolated** by repo track (`v1/stable`, `v2/stable`). Moving to a
  new major means installing a new repo config on purpose, never a silent
  firmware update.

## Consequences

- `next`'s Makefile always carries `PLUGIN_DEVEL=yes` and the next planned
  version. The release runbook removes `PLUGIN_DEVEL` on the release branch.
- Release notes list the supported OPNsense series and the bundled Kamailio and
  rtpproxy versions.
- The exact pkg version string for release candidates needs checking against
  `pkg version -t` ordering before the first RC.
