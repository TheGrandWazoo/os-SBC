---
id: ADR-SBC-0011
title: "Development builds ship as plain os-sbc on an opt-in devel track"
kind: adr
status: accepted
date: 2026-11-27
decided: 2026-11-27
deciders: [Kevin Adams]
supersedes: []
related: [ADR-SBC-0005, ADR-SBC-0004, ADR-SBC-0006, ADR-SBC-0009, FR-SBC-PKG-0001, NFR-SBC-0005]
---

# ADR-SBC-0011: Development builds ship as plain os-sbc on an opt-in devel track

> **In short:** OPNsense hides plugins whose name ends in `-devel` unless the
> firewall runs development firmware, so `os-sbc-devel` never appeared in
> the plugin list. Development builds from `next` now ship as plain
> `os-sbc` on the devel track, and that track is off by default: testers
> switch it on, production firewalls only ever see releases.

This supersedes the **Channels** table row for `next` and the related
consequence ("next's Makefile always carries PLUGIN_DEVEL=yes") in
ADR-SBC-0005. The rest of ADR-SBC-0005 stands.

## Context

On the first real install (2026-11-27, #4) the plugin list on an OPNsense
26.7.10 firewall did not show `os-sbc-devel` although the KSA-devel
repository served it. OPNsense's `FirmwareController` lists a remote
`os-*-devel` package only when the product itself is `opnsense-devel`.
Keeping the `-devel` name would mean every build before 1.0 can only be
installed from a shell, which defeats the goal of "add the repository and
the plugin appears as a selection".

Simply renaming creates a new risk: with both repositories enabled, pkg
picks the highest version, and a devel build (`1.0.0_57`) sorts above the
release it precedes (`1.0.0`). Production firewalls must not be offered
devel builds by accident.

## Decision

- `next`'s Makefile does not set `PLUGIN_DEVEL`. Every build is named
  `os-sbc`; devel builds keep the CI run number as package revision so each
  one is an upgrade (`os-sbc-1.0.0_57`).
- The devel track is **opt-in**. `os-ksa-repo` 1.1 installs `KSA-devel`
  disabled. Creating the marker file `/usr/local/etc/pkg/KSA-devel.enable`
  turns it on; the bootstrap's firmware script applies it whenever OPNsense
  rewrites repository configuration, so the choice survives firmware
  updates.
- Release branches build the same name. A firewall follows whichever
  repositories are enabled: stable only (default), or stable plus devel
  (testers, who then get the newest build).

## Alternatives considered

- **Keep `os-sbc-devel` (Option A).** Matches OPNsense's own convention, but
  nothing is visible in the plugin list until 1.0.
- **Run development firmware on test boxes.** Changes the whole firewall's
  update channel; not acceptable on production hardware.

## Consequences

- A firewall that installed `os-sbc-devel` must switch once: remove
  `os-sbc-devel`, install `os-sbc` (the two conflict by design). Steps in the
  README.
- Leaving the devel track later does not downgrade: pkg keeps the newer
  devel build until a release overtakes it, or it is reinstalled from KSA.
- The release runbook no longer edits `PLUGIN_DEVEL` when cutting
  `release/N.x`.
