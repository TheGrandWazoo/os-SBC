---
id: ADR-SBC-0010
title: "Build Kamailio and rtpproxy on hosted FreeBSD VMs, against OPNsense's own packages"
kind: adr
status: accepted
date: 2026-11-27
decided: 2026-11-27
deciders: [Kevin Adams]
supersedes: []
related: [ADR-SBC-0007, ADR-SBC-0002, ADR-SBC-0009, FR-SBC-PKG-0001]
---

# ADR-SBC-0010: Build Kamailio and rtpproxy on hosted FreeBSD VMs, against OPNsense's own packages

> **In short:** ADR-SBC-0007 planned a self-hosted FreeBSD builder in the
> lab for Kamailio and rtpproxy. A GitHub-hosted FreeBSD VM does the job in
> about 15 minutes, so no lab builder is needed. The build installs every
> dependency OPNsense ships from OPNsense's own repository and compiles only
> the rest, so the packages fit a real firewall.

This supersedes the `deps` row of ADR-SBC-0007's table. The rest of
ADR-SBC-0007 stands.

## Context

OPNsense does not ship Kamailio or rtpproxy (ADR-SBC-0002). FreeBSD's
ready-made packages can't be copied onto a firewall: OPNsense disables
FreeBSD's repositories, and FreeBSD's builds link against FreeBSD's versions
of shared libraries and, for Kamailio, pull in Oracle's MySQL client.

ADR-SBC-0007 assumed a full poudriere build would be too slow for a hosted
runner. In practice only a handful of ports need compiling once OPNsense's
binaries cover the rest: the first build (#5, PR #17) took about 15 minutes.

## Decision

The `deps` workflow (`.github/workflows/deps.yml`) builds on a GitHub-hosted
FreeBSD VM (`vmactions/freebsd-vm`, 4 cores, 12 GB) with
`.github/scripts/build-deps.sh`:

1. pkg uses only OPNsense's repository for the series, checked with
   OPNsense's fingerprint; anything the VM image installed is replaced by
   OPNsense's build where one exists.
2. The ports tree and `make.conf` come from opnsense/ports and opnsense/tools
   at the pinned release (`deps/build.conf`, now 26.7.10), plus our options
   (`deps/make.conf.local`).
3. Dependencies OPNsense ships are installed as OPNsense binaries; only the
   rest is compiled.
4. Only the ports and their runtime dependencies that OPNsense lacks are
   packaged.
5. The build fails unless Kamailio has every module DES-SBC-0001 needs, the
   disabled options left no modules behind, and an install dry run on an
   empty database with only OPNsense plus our packages resolves everything
   without shadowing an OPNsense package.

Builds run on pull requests that change the inputs; `next` publishes the
`deps` release, which opnsense-repo puts on every track (ADR-SBC-0009).

First result (OPNsense 26.7.10): 7 packages hosted (kamailio, rtpproxy,
libsrtp2, libsndfile, bcg729, gsm, libg722); a firewall install pulls 8 more
from OPNsense; 60 MiB in total; no MySQL.

## Alternatives considered

- **Self-hosted poudriere builder (ADR-SBC-0007).** Unnecessary at this size;
  keep it in mind if the dependency set grows or hosted VMs become too slow.
- **Copy FreeBSD's packages.** Rejected for the reasons in Context.

## Consequences

- No builder VM to maintain; the lab is only needed for integration tests (#6).
- Each new OPNsense release that changes library versions needs a bump of
  `OPNSENSE_RELEASE` in `deps/build.conf`; merging it rebuilds and republishes.
- The `pkg` in the build VM is OPNsense's (older than FreeBSD's), matching
  what firewalls run.
